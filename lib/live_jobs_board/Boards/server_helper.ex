defmodule ServerHelper do

  def get_server_from_id(id) do
    id |> return_pid(:gproc.where({:n, :l, {:board, id}}))
  end

  defp return_pid(id, :undefined) do
    {:ok, server} = DynamicSupervisor.start_child(ServerSupervisor, {BoardServer, id})

    GenServer.cast(server, {:set_schema, make_sample_schema()})
    server
  end

  def make_sample_schema do
    %{
      name: JobField.text_field(),
      location: JobField.option_field(["London", "Manchester", "Amsterdam"]),
      skills: JobField.multiple_choice_field((["Developer", "Data scientist", "Project manager"])),
      posted: JobField.date_field()
    }
  end

  def sample_data do
    %{
      name: JobField.text_field(make_a_string),
      location: JobField.option_field(Enum.random(["London", "Manchester", "Amsterdam"]), ["London", "Manchester", "Amsterdam"]),
      skills: JobField.multiple_choice_field([Enum.random(["Developer", "Data scientist", "Project manager"])], ["Developer", "Data scientist", "Project manager"]),
      posted: JobField.date_field()
    }
  end

  defp make_a_string do
    Faker.Superhero.name
  end

  defp return_pid(id, pid) do
    pid
  end

end
