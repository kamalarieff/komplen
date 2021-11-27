defmodule KomplenWeb.Router do
  use KomplenWeb, :router

  alias Komplen.Accounts

  pipeline :browser do
    plug :accepts, ["html"]
    plug :put_root_layout, {KomplenWeb.LayoutView, :root}
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", KomplenWeb do
    pipe_through :browser

    # get "/", PageController, :index

    live "/complaints", ComplaintLive.Index, :index
    live "/complaints/new", ComplaintLive.Index, :new
    live "/complaints/:id/edit", ComplaintLive.Index, :edit

    live "/complaints/:id", ComplaintLive.Show, :show
    live "/complaints/:id/show/edit", ComplaintLive.Show, :edit

    # resources "/users", UserController
    live "/users", UserLive.Index, :index
    live "/users/new", UserLive.Index, :new
    live "/users/:id/edit", UserLive.Index, :edit

    live "/users/:id", UserLive.Show, :show
    live "/users/:id/show/edit", UserLive.Show, :edit

    #j resources "/admins", AdminController
    live "/admins", AdminLive.Index, :index
    live "/admins/new", AdminLive.Index, :new
    live "/admins/:id/edit", AdminLive.Index, :edit

    live "/admins/:id", AdminLive.Show, :show
    live "/admins/:id/show/edit", AdminLive.Show, :edit
    resources "/sessions", SessionController, only: [:new, :create, :delete], singleton: true

    live "/rooms", RoomLive.Index, :index
    live "/rooms/new", RoomLive.Index, :new
    live "/rooms/:id/edit", RoomLive.Index, :edit

    live "/rooms/:id", RoomLive.Show, :show
    live "/rooms/:id/show/edit", RoomLive.Show, :edit

    pipe_through :auth
    # resources "/complaints", ComplaintController, except: [:index, :show]
    resources "/profile", ProfileController, only: [:show, :edit, :update], singleton: true
  end

  # TODO: should move this to a module plug instead
  def auth(conn, _opts) do
    user_id =
      conn
      |> get_session("user_id")

    case user_id do
      nil ->
        conn
        |> put_flash(:error, "Unauthorized")
        |> Phoenix.Controller.redirect(to: "/sessions/new")
        |> halt

      _ ->
        case Accounts.authenticate_by_id(user_id) do
          {:error, :unauthorized} ->
            conn
            |> put_flash(:error, "Unauthorized")
            |> Phoenix.Controller.redirect(to: "/sessions/new")
            |> halt

          {:ok, user} ->
            conn
            |> put_session("user_id", user.id)
        end
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", KomplenWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: KomplenWeb.Telemetry
    end
  end
end
