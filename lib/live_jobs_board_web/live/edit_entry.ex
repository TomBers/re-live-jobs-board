defmodule LiveJobsBoardWeb.EditEntry do
  use Phoenix.LiveView


  def render(assigns) do
    ~L"""
    <div>
      <h1>Edit</h1>
      <form action="/board/<%= assigns.session.board_id %>/entry/<%= assigns.session.entry_id %>/update" method="post" enctype="multipart/form-data">
      <%= render_logo(assigns.session) %>
      <%= for field <- assigns.session.schema do %>
        <div><%= render_input(field) %></div>
      <% end %>
      <div class="form-group">
    <label>Photo</label>
    </div>
      <input type="hidden" name="_csrf_token" value="<%= assigns.session.csrf_token %>" />
      <input type="submit" value="Submit">
      </form>
    </div>
    """
  end

  def render_input(assigns) do
    assigns = Enum.into(assigns, %{})
    ~L"""
    <div>
        <%= case assigns.type do
           "OPTION" -> render_option_field(assigns)
           "MULTIPLECHOICE" -> render_multiple_choice_field(assigns)
           "TEXT" -> render_text_field(assigns)
           _ -> ""
        end%>
    </div>
    """
  end

  def render_multiple_choice_field(assigns) do
    assigns = Enum.into(assigns, %{})
    ~L"""
        <%= assigns.field_name %><br>
        <%= for field <- assigns.options do %>
          <label for="<%= remove_space(field) %>">
            <input name="::<%= assigns.field_name%>_<%= field %>" id="<%= remove_space(field) %>" type="checkbox" <%= if Enum.member?(assigns.value, field), do: "checked" %>/>
            <span><%= field %></span>
          </label>
        <% end %>
    """
  end

  def remove_space(words) do
    String.replace(words, " ", "_")
  end

  def render_option_field(assigns) do
    assigns = Enum.into(assigns, %{})
    ~L"""
      <%= assigns.field_name %>
      <select name="<%= assigns.field_name %>" class="browser-default">
        <%= for field <- assigns.options do %>
          <option value="<%= field %>" <%= if assigns.value == field, do: "selected" %> ><%= field %></option>
        <% end %>
    </select>

    """
  end

  def render_text_field(assigns) do
    assigns = Enum.into(assigns, %{})

    ~L"""
    <%= assigns.field_name %> <input type="text" name="<%= assigns.field_name %>" value="<%= assigns.value %>">

    """
  end

  def render_logo(assigns) do
     logo = Enum.find(assigns.schema, %{value: ""}, fn(ele) -> ele.field_name == :logo end)

    ~L"""
    <h3>Logo</h3>
    <%= if logo.value != "" do %>
      <img class="logo" src="/images/<%= logo.value %>"></img>
      <a href="#" phx-click="remove-logo" phx-value="<%= Jason.encode!(assigns) %>" onClick="window.location.reload();">Remove</a>
    <% else %>
      <input class="form-control" id="logo_photo" name="logo" type="file">
    <% end %>


    """
  end

  def handle_event("remove-logo", params, socket) do
    %{"board_id" => board_id, "entry_id" => entry_id} = Jason.decode!(params)
    pid = ServerHelper.get_server_from_id(board_id)
    logo_field = [{"logo", ""}]
    GenServer.cast(pid, {:update_job, String.to_integer(entry_id), logo_field})
    {:noreply, socket}
  end

end