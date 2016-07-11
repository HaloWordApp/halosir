defmodule HaloSir.Router do
  use HaloSir.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", HaloSir do
    pipe_through :api
  end

  scope "/youdao", HaloSir do
    get "/query/:word", YoudaoController, :query
  end

  scope "/webster", HaloSir do
    get "/query/:word", WebsterController, :query
  end
end
