defmodule LiveJobsBoardWeb.ClickLive do
  use Phoenix.LiveView


  def render(assigns) do
    ~L"""
    <div>
      <h1>Clicker</h1>
      <button phx-click="click" class="minus">Give it a click</button>
      <p><%= @rand %></p>
      <div class="flex-container">
        <%= for %{field: field, value: value} <- @filters do %>
          <div>Field: <%= field %> - <%= value %></div>
        <% end %>
        <%= for job <- @tst do %>
          <div class="flex-item">
            <%= for {k,v} <- job do %>
              <%= render_field(%{key: k, field: v}) %>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  def render_field(assigns) do
#    IO.inspect(assigns)
    assigns = Enum.into(assigns, %{})

    ~L"""
    <div>
      <%= if assigns.key != :id do %>
        <%= assigns.key %> ::
          <%= for val <- JobField.return_val(assigns.field) do %>
                <a href="#" phx-click="filter" phx-value="<%= JobField.encode(assigns, val) %>" ><%= val %></a>
          <% end %>
      <%= end %>
    </div>
    """
  end

  def mount(%{path_params: %{"board_id" => id}}, socket) do
    {:ok, assign(socket, rand: getrand(), tst: get_jobs(), filters: [])}
  end

  def handle_event("click", _, socket) do
    {:noreply, assign(socket, rand: getrand())}
  end

  def handle_event("filter", params, socket) do
    filters = socket.assigns.filters
    %{"field_name" => name, "type" => _, "value" => val} = Jason.decode!(params)
    {:noreply, assign(socket, filters: filters |> List.insert_at(-1, %{field: name, value: val}))}
  end

  defp getrand() do
    Enum.random(1..100)
  end

  def get_jobs() do
    [
      %{
        id: 1,
        location: %JobField{
          options: ["London", "Manchester", "Amsterdam"],
          type: "OPTION",
          value: ["Manchester"]
        },
        name: %JobField{options: [], type: "TEXT", value: ["Name1"]},
        posted: %JobField{options: [], type: "DATE", value: [~D[2019-01-22]]},
        skills: %JobField{
          options: ["Developer", "Data scientist", "Project manager"],
          type: "MULTIPLECHOICE",
          value: ["Developer", "Data scientist", "Project manager"]
        },
      },
      %{
        id: 2,
        location: %JobField{
          options: ["London", "Manchester", "Amsterdam"],
          type: "OPTION",
          value: ["London"]
        },
        name: %JobField{options: [], type: "TEXT", value: ["Name 2"]},
        posted: %JobField{options: [], type: "DATE", value: [~D[2019-01-22]]},
        skills: %JobField{
          options: ["Developer", "Data scientist", "Project manager"],
          type: "MULTIPLECHOICE",
          value: ["Developer"]
        }
      }
    ]

  end

end