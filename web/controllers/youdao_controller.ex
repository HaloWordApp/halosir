defmodule HaloSir.YoudaoController do
  use HaloSir.Web, :controller

  @api_base "https://fanyi.youdao.com/fanyiapi.do?type=data&doctype=json&version=1.1\
&keyfrom=#{Application.get_env(:halosir, __MODULE__)[:keyfrom]}\
&key=#{Application.get_env(:halosir, __MODULE__)[:key]}\
&" # To append `q=xxx`

  plug :youdao_headers

  def query(conn, %{"word" => word}) do
    case HaloSir.RiakStore.get("youdao", word) do
      {:ok, cached_obj} ->
        # Use cached result
        result = :riakc_obj.get_values(cached_obj) |> hd
        text(conn, result)
      {:error, :notfound} ->
        # Query server and cache the result
        result = HTTPotion.get!(@api_base <> URI.encode_query(%{"q" => word})).body

        obj = :riakc_obj.new("youdao", word, result, "text/plain")
        HaloSir.RiakStore.put(obj)

        text(conn, result)
      _ ->
        halt(conn)
    end
  end

  defp youdao_headers(conn, _opts) do
    conn
    |> put_resp_header("cache-control", Application.get_env(:halosir, :cache_control))
    |> put_resp_content_type("application/json")
  end

end
