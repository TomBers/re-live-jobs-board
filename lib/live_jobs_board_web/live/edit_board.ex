defmodule LiveJobsBoardWeb.EditBoard do
  use Phoenix.LiveView


  def render(assigns) do
    ~L"""
    <div>
      <h1>Edit</h1>
      <%= for field <- @schema do %>
        <div class="form-box"><%= render_input(field) %></div>
      <% end %>
      <a href="#" phx-click="add-field" >Add field</a></p>
      <%= if assigns.new_field do %>
        <form phx-change="add-new-field-text">
          <input type="text" name="new-field">
          <a href="#" phx-click="add-new-field-confirm" phx-value="new-field">Save field</a>
        </form>
      <% end %>
      <input type="submit" value="Submit" phx-click="save-schema" class="btn waves-effect waves-light">
    </div>
    """
  end

  def render_input(assigns) do
    assigns = Enum.into(assigns, %{})
    ~L"""
    <div>
    <form phx-change="update-field">
        <select name="<%= assigns.field_name %>" class="browser-default">
          <option value="TEXT" <%= if assigns.type == "TEXT", do: "selected" %> >Text</option>
          <option value="OPTION" <%= if assigns.type == "OPTION", do: "selected" %> >Single choice</option>
          <option value="MULTIPLECHOICE" <%= if assigns.type == "MULTIPLECHOICE", do: "selected" %> >Multiple choice</option>
        </select>
      </form>
        <%= render_text_field(assigns) %>
        <%= case assigns.type do
           "OPTION" -> render_options(assigns)
            "MULTIPLECHOICE" -> render_options(assigns)
           _ -> ""
        end%>
    </div>
    """
  end


  def render_options(assigns) do
    assigns = Enum.into(assigns, %{})
    ~L"""
        <%= for field <- assigns.options do %>
          <p><%= field %> <a href="#" phx-click="remove-option" phx-value="<%= Jason.encode!(%{field: assigns.field_name, option: field}) %>" >remove</a></p>
        <% end %>
        <p>Add options</p>
        <form phx-change="add-option-text">
          <input type="text" name="<%= assigns.field_name %>">
          <a href="#" phx-click="add-option-confirm" phx-value=<%= assigns.field_name %>>Add</a>
        </form>
    """
  end

  def render_text_field(assigns) do
    assigns = Enum.into(assigns, %{})

    ~L"""
    <input type="text" name="<%= assigns.field_name %>" value="<%= assigns.field_name %>">

    """
  end



  def mount(%{path_params: %{"board_id" => id}}, socket) do
    pid = ServerHelper.get_server_from_id(id)
    board = GenServer.call(pid, :list)
    IO.inspect(board)
    dat = board.schema
      |> Enum.filter(fn({k, v}) -> k not in [:posted, :logo] end)
      |> Enum.map(fn({k, v}) -> v |> Map.put(:field_name, k) end)


    {:ok, assign(socket, board_id: id, schema: dat, new_options: %{}, new_field: false, new_field_name: "")}
  end

  def handle_event("save-schema", params, socket) do
    id = socket.assigns.board_id
    pid = ServerHelper.get_server_from_id(id)
    schema = socket.assigns.schema |> convert_to_map
    GenServer.cast(pid, {:set_schema, schema})

    {:noreply, socket}
  end

  def convert_to_map(schema) do
    schema
    |> Enum.map(fn(field) -> {field.field_name, field} end)
    |> Map.new
  end

  def handle_event("update-field", params, socket) do
    schema = socket.assigns.schema
    key = Map.keys(params) |> List.first
    value = Map.values(params) |> List.first

    field_name = String.to_atom(key)
    index = schema |> Enum.find_index(fn(field) -> field.field_name == field_name end)
    field_map = Enum.at(schema, index)

    new_field = put_in(field_map.type, value)

    {:noreply, assign(socket, schema: List.replace_at(schema, index, new_field))}
  end

  def handle_event("remove-option", params, socket) do
    schema = socket.assigns.schema
    %{"field" => field, "option" => option} = Jason.decode!(params)
    {:noreply, assign(socket, schema: modify_options(schema, field, option, false))}
  end

  def handle_event("add-option-text", params, socket) do
    new_options = socket.assigns.new_options
    key = Map.keys(params) |> List.first
    value = Map.values(params) |> List.first


    {:noreply, assign(socket, new_options: Map.put(new_options, key, value))}
  end

  def handle_event("add-option-confirm", params, socket) do
    schema = socket.assigns.schema
    new_options = socket.assigns.new_options
    field = params
    option = Map.get(new_options, field)

    {:noreply, assign(socket, schema: modify_options(schema, field, option, true), new_options: Map.delete(new_options, field))}
  end

  def handle_event("add-field", params, socket) do
    {:noreply, assign(socket, new_field: true)}
  end

  def handle_event("add-new-field-text", %{"new-field" => name}, socket) do
    {:noreply, assign(socket, new_field_name: name)}
  end

  def handle_event("add-new-field-confirm", params, socket) do
    schema =
      case socket.assigns.new_field_name != "" do
        true -> socket.assigns.schema ++ [Map.put(JobField.text_field(), :field_name, String.to_atom(remove_space(socket.assigns.new_field_name)))]
        false -> socket.assigns.schema
    end

    IO.inspect(schema)

    {:noreply, assign(socket, schema: schema, new_field_name: "", new_field: false)}
  end

  def remove_space(words) do
    String.replace(words, " ", "_")
  end


  def modify_options(schema, field, option, add_or_take) do

    field_name = String.to_atom(field)
    index = schema |> Enum.find_index(fn(field) -> field.field_name == field_name end)
    field_map = Enum.at(schema, index)

    new_field =
      case add_or_take do
        true -> put_in(field_map.options, field_map.options ++ [option])
        false -> put_in(field_map.options, field_map.options -- [option])
      end
    List.replace_at(schema, index, new_field)
  end


end