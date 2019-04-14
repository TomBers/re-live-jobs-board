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

    live "/thermostat", ThermostatLive
    live "/click", ClickLive
    live "/board/:board_id", BoardSearch
    live "/board/:board_id/edit", EditBoard
    live "/board/:board_id/entry/:entry_id", EditEntry
    get "/board/:board_id/entry/:entry_id/update", PageController, :update_entry
    get "/snake", PageController, :snake
    live "/search", SearchLive
    live "/clock", ClockLive
    live "/image", ImageLive
    live "/pacman", PacmanLive
    live "/rainbow", RainbowLive
    live "/counter", CounterLive
    live "/top", TopLive
    live "/presence_users/:name", UserLive.PresenceIndex
    live "/users", UserLive.Index
    live "/users/new", UserLive.New
    live "/users/:id", UserLive.Show
    live "/users/:id/edit", UserLive.Edit

    resources "/plain/users", UserController
  end
end
