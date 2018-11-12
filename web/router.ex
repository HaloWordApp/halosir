defmodule HaloSir.Router do
  use HaloSir.Web, :router

  scope "/youdao", HaloSir do
    get "/query/:word", YoudaoController, :query
  end

  scope "/webster", HaloSir do
    get "/query/:word", WebsterController, :query
  end
end
