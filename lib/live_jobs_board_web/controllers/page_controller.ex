defmodule LiveJobsBoardWeb.PageController do
  use LiveJobsBoardWeb, :controller

  alias Phoenix.LiveView

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def get_entry(conn, %{"board_id" => id, "entry_id" => entry_id}) do
    pid = ServerHelper.get_server_from_id(id)
    {schema, entry} = GenServer.call(pid, {:get_item, String.to_integer(entry_id)})
    data =
      schema
      |> Enum.map(fn({k, v}) -> {k, v |> Map.put(:value, get_value_from_field(k, v, entry))} end)
      |> Enum.map(fn({k, v}) -> v |> Map.put(:field_name, k) end)

    Phoenix.LiveView.Controller.live_render(conn, LiveJobsBoardWeb.EditEntry, session: %{ board_id: id, entry_id: entry_id, schema: data, csrf_token: Phoenix.Controller.get_csrf_token() })
  end

  def get_value_from_field(key, field, entry) do
    case field.type do
      "MULTIPLECHOICE" -> Map.get(entry, key, %{value: [""]}).value
      _ -> Map.get(entry, key, %{value: ""}).value
    end

  end

  def update_entry(conn, params) do
    board_id = params["board_id"]
    id = params["entry_id"]
    form_values =
      params
      |> Enum.filter(fn({key, value}) -> key not in ["board_id", "entry_id", "_csrf_token", "logo"] end)
      |> Enum.filter(fn({key, value}) -> !String.starts_with?(key, "::") end)

    check_box_values = params |> Enum.filter(fn({key, value}) -> String.starts_with?(key, "::") end)

    pid = ServerHelper.get_server_from_id(board_id)
    GenServer.cast(pid, {:update_job, String.to_integer(id), form_values ++ transform(check_box_values) ++ deal_with_logo(board_id, id, Map.get(params, "logo"))})
    conn
    |> redirect(to: "/board/#{board_id}")
  end

  def deal_with_logo(_, _, nil) do
    []
  end

  def deal_with_logo(board_id, entry_id, %Plug.Upload{content_type: content_type, filename: filename, path: path}) do
    extension = Path.extname(filename)
    new_file = "#{board_id}#{entry_id}#{extension}"
    File.cp(path, "priv/static/images/#{new_file}")
    [{"logo", "#{new_file}"}]
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
