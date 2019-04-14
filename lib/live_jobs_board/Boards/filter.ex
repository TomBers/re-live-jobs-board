defmodule BoardFilter do

  def get_jobs(board, []) do
    board
    board.entries |> Enum.map(fn({_id, entry}) -> Map.merge(board.schema, entry) end)
  end

  def get_jobs(board, filters) when is_list(filters) do
    [%{field: criteria, value: term} | tail] = filters
    new_board = get_jobs(board, criteria, term)
    get_jobs(new_board,  tail)
  end

  def get_jobs(board, "n", "a") do
    board
  end

  def get_jobs(board, criteria, term) do
    new_entries = board.entries
                  |> Enum.filter(fn({_id, entry}) -> match_criteria(entry, criteria, term) end)
    case new_entries do
      [] -> board
      _ -> Map.replace(board, :entries, new_entries)
    end
  end

  def match_criteria(entry, "posted", term) do
    {:ok, dt} = Date.from_iso8601(term)
    case Date.compare(dt, entry.posted.value) do
      :gt -> false
      :lt -> true
      _ -> true
    end
  end

  def match_criteria(entry, criteria, term) do
    val = Map.get(entry, String.to_atom(criteria))
    does_match(val, term)
  end

  def does_match(map, term) when is_map(map) do
    does_match(map.value, term)
  end

  def does_match(value, term) when is_list(term) do
    term |> Enum.map(fn(x) -> Enum.member?(value, x) end) |> Enum.any?
  end

  def does_match(value, term) when is_list(value) do
    Enum.member?(value, term)
  end

  def does_match(value, term) do
    value == term
  end

end
