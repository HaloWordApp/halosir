defmodule HaloSirWeb.YoudaoController do
  @moduledoc false
  use HaloSirWeb, :controller
  alias HaloSir.{Rules, DetsStore, QueryClient}

  plug :response_headers

  def query(conn, %{"word" => word}) do
    case DetsStore.get(:youdao, word) do
      {:ok, cached_result} ->
        Telemetry.execute([:halosir, :youdao, :dets_get], 1, %{cached?: true})
        DetsStore.incr(:youdao, word)
        text(conn, cached_result)
      {:error, :notfound} ->
        Telemetry.execute([:halosir, :youdao, :dets_get], 1, %{cached?: false})

        resp = word
          |> query_url()
          |> QueryClient.get!()

        if resp.status != 200 do
          Telemetry.execute([:halosir, :youdao, :query], 1, %{success?: false})
          resp(conn, resp.status, resp.body)
        else
          Telemetry.execute([:halosir, :youdao, :query], 1, %{success?: true})

          result = Map.get(resp, :body)

          if Rules.should_cache_word?(word) do
            DetsStore.put(:youdao, word, result)
            Telemetry.execute([:halosir, :youdao, :dets_put], 1)
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

      config[:api_base] <> args
    end
  end

  defp response_headers(conn, _opts) do
    conn
    |> put_resp_header("cache-control", Application.get_env(:halosir, :cache_control))
    |> put_resp_content_type("application/json")
  end
end
