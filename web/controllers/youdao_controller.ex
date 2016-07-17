defmodule HaloSir.YoudaoController do
  use HaloSir.Web, :controller
  alias HaloSir.Rules

  @query_url_base "https://fanyi.youdao.com/fanyiapi.do?type=data&doctype=json&version=1.1" <>
    "&keyfrom=#{Application.get_env(:halosir, __MODULE__)[:keyfrom]}" <>
    "&key=#{Application.get_env(:halosir, __MODULE__)[:key]}&q="

  plug :youdao_headers

  def query(conn, %{"word" => word}) do
    case HaloSir.DetsStore.get(:youdao, word) do
      {:ok, cached_result} ->
        # Use cached result
        HaloSir.DetsStore.incr(:youdao, word)

        text(conn, cached_result)
      {:error, :notfound} ->
        # Query server and cache the result
        result =
          @query_url_base
          |> Kernel.<>(URI.encode_www_form(word))
          |> HTTPotion.get!()
          |> Map.get(:body)

        if Rules.should_cache_word?(word) do
          HaloSir.DetsStore.put(:youdao, word, result)
        end

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
