defmodule LiveJobsBoardWeb.Router do
  use LiveJobsBoardWeb, :router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_layout, {LiveJobsBoardWeb.LayoutView, :app}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LiveJobsBoardWeb do
    pipe_through :browser

    get "/", PageController, :index

    live "/board/:board_id", BoardSearch
    live "/board/:board_id/edit", EditBoard
    get "/board/:board_id/entry/:entry_id", PageController, :get_entry
    post "/board/:board_id/entry/:entry_id/update", PageController, :update_entry
  end
end
