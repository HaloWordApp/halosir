defmodule HaloSirWeb.Router do
  use HaloSirWeb, :router

  scope "/youdao", HaloSirWeb do
    get "/query/:word", YoudaoController, :query
  end

  scope "/webster", HaloSirWeb do
    get "/query/:word", WebsterController, :query
  end
end
