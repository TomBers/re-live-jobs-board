defmodule LiveJobsBoardWeb.UserLive.PresenceIndex do
  use Phoenix.LiveView

  alias LiveJobsBoard.Accounts
  alias LiveJobsBoardWeb.{UserView, Presence}
  alias Phoenix.Socket.Broadcast

  def mount(%{path_params: %{"name" => name}}, socket) do
    LiveJobsBoard.Accounts.subscribe()
    Phoenix.PubSub.subscribe(LiveJobsBoard.PubSub, "users")
    Presence.track(self(), "users", name, %{})
    {:ok, fetch(socket)}
  end

  def render(assigns), do: UserView.render("index.html", assigns)

  defp fetch(socket) do
    assign(socket, %{
      users: Accounts.list_users(),
      online_users: LiveJobsBoardWeb.Presence.list("users")
    })
  end

  def handle_info(%Broadcast{event: "presence_diff"}, socket) do
    {:noreply, fetch(socket)}
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
