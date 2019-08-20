defmodule LiveJobsBoardWeb.BoardSearch do
  use Phoenix.LiveView


  def render(assigns) do
    ~L"""
    <div>
      <h1>Jobs?</h1>
      <p><a href="/board/<%= @board_id %>/edit">edit board</a></p>
      <h5>Filters</h5>
      <%= for %{field: field, value: value} = filter <- @filters do %>
          <div><%= field %> :: <%= value %> <a href="#" phx-click="remove-filter" phx-value="<%= Jason.encode!(filter) %>" >remove</a></div>
        <% end %>
      <div class="flex-container">
        <%= for job <- @jobs do %>
          <div class="flex-item">
            <%= render_logo(job.logo) %>
            <%= for {k,v} <- job do %>
              <%= render_field(%{key: k, field: v}) %>
            <% end %>
          <a href="/board/<%= @board_id %>/entry/<%= job.id %>">edit</a>
          </div>

        <% end %>
      </div>
    </div>
    """
  end

  def render_field(assigns) do
    assigns = Enum.into(assigns, %{})

    ~L"""
    <div>
      <%= if assigns.key not in [:id, :logo] do %>
        <%= assigns.key %> ::
          <%= for val <- JobField.return_val(assigns.field) do %>
                <a href="#" phx-click="filter" phx-value="<%= JobField.encode(assigns, val) %>" ><%= val %></a>
          <% end %>
      <%= end %>
    </div>
    """
  end

  def render_logo(assigns) do
    logo = Enum.into(assigns, %{})
    ~L"""
    <div>
    <%= if logo.value != "" do %>
    <img class="logo" src="/images/<%= logo.value %>"></img>
    <% end %>
    </div>
    """
  end

  def mount(%{path_params: %{"board_id" => id}}, socket) do
    pid = ServerHelper.get_server_from_id(id)
    jobs = BoardFilter.get_jobs(GenServer.call(pid, :list), [])
    {:ok, assign(socket, board_id: id, jobs: jobs, filters: [])}
  end


  def handle_event("filter", params, socket) do
    pid = ServerHelper.get_server_from_id(socket.assigns.board_id)
    filters = socket.assigns.filters
    board = GenServer.call(pid, :list)
    %{"field_name" => name, "type" => _, "value" => val} = Jason.decode!(params)
    new_filters = filters |> List.insert_at(-1, %{field: name, value: val})


    {:noreply, assign(socket, filters: new_filters, jobs: BoardFilter.get_jobs(board, new_filters))}
  end

  def handle_event("remove-filter", params, socket) do
    pid = ServerHelper.get_server_from_id(socket.assigns.board_id)
    filters = socket.assigns.filters
    board = GenServer.call(pid, :list)

    %{"field" => field, "value" => val} = Jason.decode!(params)
    new_filters = List.delete(filters, %{field: field, value: val})
    {:noreply, assign(socket, filters: new_filters, jobs: BoardFilter.get_jobs(board, new_filters))}
  end

end