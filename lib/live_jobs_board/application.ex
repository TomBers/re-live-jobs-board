defmodule LiveJobsBoard.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      LiveJobsBoard.Repo,
      LiveJobsBoardWeb.Endpoint,
      LiveJobsBoardWeb.Presence,
      {DynamicSupervisor, strategy: :one_for_one, name: ServerSupervisor}
    ]

    opts = [strategy: :one_for_one, name: LiveJobsBoard.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    LiveJobsBoardWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
