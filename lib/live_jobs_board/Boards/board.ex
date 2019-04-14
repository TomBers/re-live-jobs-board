defmodule Board do
  @derive {Jason.Encoder, only: [:entries, :schema]}

  defstruct auto_id: 1, entries: %{}, name: "", schema: %{}


  def new(), do: %Board{name: Faker.Pokemon.name()}

  def new(name), do: %Board{name: name}

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      new(),
      fn(entry, acc) -> add_entry(acc, entry) end
    )
  end

  def set_schema(board, schema) do
    %Board{board | schema: schema}
  end

  def add_entry(board, entry) do
    entry = Map.put(entry, :id, board.auto_id)
    new_entries = Map.put(board.entries, board.auto_id, entry)
    %Board{board | entries: new_entries, auto_id: board.auto_id + 1}
  end

  def remove_entry(board, entry) do
    {_, new_entries} = pop_in(board.entries, [entry.id])
    new_data =
      new_entries
      |> Enum.map(fn({_id, data}) -> data end)
    new(new_data)
  end

  def update_name(board, id, new_name) do
    put_in(board.entries[id].name, new_name)
  end

  def update_ops(board, id, new_ops) do
    put_in(board.entries[id].ops, new_ops)
  end

  def update_description(board, id, new_description) do
    put_in(board.entries[id].description, new_description)
  end

  def update_job(board, id, new_job) do
    put_in(board.entries[id], new_job)
  end

  def update_entry(board, %{} = new_entry) do
    update_entry(board, new_entry.id, fn _ -> new_entry end)
  end

  def update_entry(board, entry_id, update_fun) do
    case Map.fetch(board.entries, entry_id) do
      :error -> board
      {:ok, old_entry} ->
        new_entry = update_fun.(old_entry)
        new_entries = Map.put(board.entries, new_entry.id, new_entry)
        %Board{board | entries: new_entries}
    end
  end

end
