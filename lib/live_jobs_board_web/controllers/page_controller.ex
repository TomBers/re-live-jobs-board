defmodule LiveJobsBoardWeb.PageController do
  use LiveJobsBoardWeb, :controller

  alias Phoenix.LiveView

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def update_entry(conn, params) do
    board_id = params["board_id"]
    id = params["entry_id"]
    form_values =
      params
      |> Enum.filter(fn({key, value}) -> key not in ["board_id", "entry_id"] end)
      |> Enum.filter(fn({key, value}) -> !String.starts_with?(key, "::") end)

    check_box_values = params |> Enum.filter(fn({key, value}) -> String.starts_with?(key, "::") end)

    pid = ServerHelper.get_server_from_id(board_id)
    GenServer.cast(pid, {:update_job, String.to_integer(id), form_values ++ transform(check_box_values)})
    conn
    |> redirect(to: "/board/#{board_id}")
  end

  def transform(opts) do
    opts
    |> Enum.map(fn({k, _}) -> String.split(k, "_") |> Enum.map(fn(x) -> String.trim_leading(x, "::") end) end)
    |> Enum.chunk_by(fn([key, value]) -> key end)
    |> Enum.map(fn(inp) -> {return_key(inp), return_array(inp)} end)
  end

  def return_key(inp) do
    inp |> List.first |> List.first
  end
  def return_array(inp) do
    inp |> Enum.reduce([], fn([key, value], acc) -> acc ++ [value]  end)
  end

  def snake(conn, _) do
    conn
    |> put_layout(:game)
    |> LiveView.Controller.live_render(LiveJobsBoardWeb.SnakeLive, session: %{})
  end
end
