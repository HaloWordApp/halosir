defmodule HaloSir.YoudaoController do
  @moduledoc false
  use HaloSir.Web, :controller
  alias HaloSir.{Rules, DetsStore, MetricStore}

  plug :youdao_headers

  def query(conn, %{"word" => word}) do
    case DetsStore.get(:youdao, word) do
      {:ok, cached_result} ->
        DetsStore.incr(:youdao, word)

        MetricStore.write("dict_query", [dict: "youdao", cached: true], [word: word])

        text(conn, cached_result)
      {:error, :notfound} ->
        config = Application.get_env(:halosir, __MODULE__)

        resp =
          query_url(config, word)
          |> HTTPotion.get!()

        if resp.status_code != 200 do
          resp(conn, resp.status_code, resp.body)
        else
          result = Map.get(resp, :body)

          MetricStore.write("dict_query", [dict: "youdao", cached: false], [word: word])

          if Rules.should_cache_word?(word) do
            DetsStore.put(:youdao, word, result)

            MetricStore.write("dets_cache", [dict: "youdao"], [word: word])
          end

          text(conn, result)
        end
      _ ->
        halt(conn)
    end
  end

  defp query_url(config, word) do
    if Keyword.has_key?(config, :proxy) do
      encoded_word =
        word
        |> String.split
        |> Enum.map(&URI.encode_www_form/1)
        |> Enum.join(" ")

      config[:proxy] <> encoded_word
    else
      args =
        config
        |> Keyword.delete(:api_base)
        |> Keyword.merge([q: word])
        |> URI.encode_query()

      config[:api_base]
      |> Kernel.<>(args)
    end
  end

  defp youdao_headers(conn, _opts) do
    conn
    |> put_resp_header("cache-control", Application.get_env(:halosir, :cache_control))
    |> put_resp_content_type("application/json")
  end

end
