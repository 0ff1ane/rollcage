defmodule ApiServerWeb.Router do
  use ApiServerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ApiServerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Inertia.Plug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug ApiServerWeb.VerifyUserPlug
  end

  scope "/", ApiServerWeb do
    pipe_through :browser

    get "/", PageController, :login
    get "/counter", PageController, :counter
    get "/todos", PageController, :todos
  end

  # public /api routes
  scope "/api", ApiServerWeb do
    pipe_through [:api]

    post "/users", UserController, :create
  end

  # authenticated /api routes
  scope "/api", ApiServerWeb do
    pipe_through [:api, :auth]

    resources "/users", UserController, except: [:new, :delete]
  end

  # Other scopes may use custom stacks.
  # scope "/api", ApiServerWeb do
  #   pipe_through :api
  # end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:api_server, :dev_routes) do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
