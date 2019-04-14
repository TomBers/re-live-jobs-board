defmodule LiveJobsBoardWeb.UserLive.Index do
  use Phoenix.LiveView

  alias LiveJobsBoard.Accounts
  alias LiveJobsBoardWeb.UserView

  def mount(_session, socket) do
    if connected?(socket), do: LiveJobsBoard.Accounts.subscribe()
    {:ok, fetch(socket)}
  end

  def render(assigns), do: UserView.render("index.html", assigns)

  defp fetch(socket) do
    assign(socket, users: Accounts.list_users())
  end

  def handle_info({Accounts, [:user | _], _}, socket) do
    {:noreply, fetch(socket)}
  end

  def handle_event("delete_user", id, socket) do
    user = Accounts.get_user!(id)
    {:ok, _user} = Accounts.delete_user(user)

    {:noreply, socket}
  end
end
