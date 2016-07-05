defmodule HaloSir.Router do
  use HaloSir.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", HaloSir do
    pipe_through :api
  end
end
