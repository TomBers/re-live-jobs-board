defmodule LiveJobsBoardWeb.UserLive.New do
  use Phoenix.LiveView

  alias LiveJobsBoardWeb.UserLive
  alias LiveJobsBoardWeb.Router.Helpers, as: Routes
  alias LiveJobsBoard.Accounts
  alias LiveJobsBoard.Accounts.User

  def mount(_session, socket) do
    {:ok,
     assign(socket, %{
       count: 0,
       changeset: Accounts.change_user(%User{})
     })}
  end

  def render(assigns), do: LiveJobsBoardWeb.UserView.render("new.html", assigns)

  def handle_event("validate", %{"user" => params}, socket) do
    changeset =
      %User{}
      |> LiveJobsBoard.Accounts.change_user(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        {:stop,
         socket
         |> put_flash(:info, "user created")
         |> redirect(to: Routes.live_path(socket, UserLive.Show, user))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
