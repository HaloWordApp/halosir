defmodule HaloSir.YoudaoController do
  @moduledoc false
  use HaloSir.Web, :controller
  alias HaloSir.{Rules, DetsStore, MetricStore}

  plug :youdao_headers

  def query(conn, %{"word" => word}) do
    case DetsStore.get(:youdao, word) do
      {:ok, cached_result} ->
        # Use cached result
        DetsStore.incr(:youdao, word)

        MetricStore.write("dict_query", [dict: "youdao", cached: true], [word: word])

        text(conn, cached_result)
      {:error, :notfound} ->
        config = Application.get_env(:halosir, __MODULE__)

        result =
        if Keyword.has_key?(config, :proxy) do
          # If configured to use proxy, we query the proxy server instead
          encoded_word =
            word
            |> String.split
            |> Enum.map(&URI.encode_www_form/1)
            |> Enum.join(" ")

          config[:proxy] <> encoded_word
          |> HTTPotion.get!()
          |> Map.get(:body)

        else
          # Query server and cache the result
          args =
            config
            |> Keyword.delete(:api_base)
            |> Keyword.merge([q: word])
            |> URI.encode_query()

          config[:api_base]
          |> Kernel.<>(args)
          |> HTTPotion.get!()
          |> Map.get(:body)
        end

        MetricStore.write("dict_query", [dict: "youdao", cached: false], [word: word])

        if Rules.should_cache_word?(word) do
          DetsStore.put(:youdao, word, result)

          MetricStore.write("dets_cache", [dict: "youdao"], [word: word])
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
