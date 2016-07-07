defmodule HaloSir.YoudaoController do
  use HaloSir.Web, :controller

  @api_base "https://fanyi.youdao.com/fanyiapi.do?type=data&doctype=json&version=1.1&keyfrom=#{Application.get_env(:halosir, __MODULE__)[:keyfrom]}&key=#{Application.get_env(:halosir, __MODULE__)[:key]}&"

  def query(conn, %{"word" => word}) do
    result = HTTPotion.get!(@api_base <> URI.encode_query(%{"q" => word})).body

    conn
    |> put_resp_header("cache-control", Application.get_env(:halosir, :cache_control))
    |> put_resp_content_type("application/json")
    |> text result
  end

end
