defmodule HaloSirWeb.YoudaoController do
  @moduledoc false
  use HaloSirWeb, :controller
  alias HaloSir.{Rules, DetsStore, MetricStore, QueryClient}

  plug :response_headers

  def query(conn, %{"word" => word}) do
    case DetsStore.get(:youdao, word) do
      {:ok, cached_result} ->
        DetsStore.incr(:youdao, word)
        MetricStore.dict_query(:youdao, true, word)
        text(conn, cached_result)
      {:error, :notfound} ->
        resp = word
          |> query_url()
          |> QueryClient.get!()

        if resp.status != 200 do
          MetricStore.failed_query(:youdao, word)
          resp(conn, resp.status, resp.body)
        else
          result = Map.get(resp, :body)
          MetricStore.dict_query(:youdao, false, word)

          if Rules.should_cache_word?(word) do
            DetsStore.put(:youdao, word, result)
            MetricStore.dets_cache(:youdao, word)
          end

          text(conn, result)
        end
      _ ->
        halt(conn)
    end
  end

  defp query_url(word) do
    config = Application.get_env(:halosir, __MODULE__)

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

  defp response_headers(conn, _opts) do
    conn
    |> put_resp_header("cache-control", Application.get_env(:halosir, :cache_control))
    |> put_resp_content_type("application/json")
  end

end
