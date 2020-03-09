defmodule ExMmogWeb.Router do
  use ExMmogWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ExMmogWeb do
    pipe_through :browser

    get "/game", GameController, :index
    get "/*path", GameController, :index
  end
end
