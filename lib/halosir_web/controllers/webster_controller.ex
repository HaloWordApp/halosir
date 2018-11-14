defmodule HaloSirWeb.WebsterController do
  @moduledoc false
  use HaloSirWeb, :controller
  alias HaloSir.{Rules, DetsStore, QueryClient}

  plug :response_headers

  def query(conn, %{"word" => word}) do
    case DetsStore.get(:webster, word) do
      {:ok, cached_result} ->
        Telemetry.execute([:halosir, :webster, :dets_get], 1, %{cached?: true})
        DetsStore.incr(:webster, word)
        text(conn, cached_result)
      {:error, :notfound} ->
        Telemetry.execute([:halosir, :webster, :dets_get], 1, %{cached?: false})

        resp = query_webster(word)

        if resp.status != 200 do
          Telemetry.execute([:halosir, :webster, :query], 1, %{success?: false})
          resp(conn, resp.status, resp.body)
        else
          Telemetry.execute([:halosir, :webster, :query], 1, %{success?: true})

          result = Map.get(resp, :body)

          if Rules.should_cache_word?(word) do
            DetsStore.put(:webster, word, result)
            Telemetry.execute([:halosir, :webster, :dets_put], 1)
          end

          text(conn, result)
        end
      _ ->
        halt(conn)
    end
  end

  defp query_webster(word) do
    key =
      Application.get_env(:halosir, __MODULE__)[:keys]
      |> Enum.random()

    Application.get_env(:halosir, __MODULE__)[:api_eex]
    |> EEx.eval_string([word: URI.encode_www_form(word), key: key])
    |> QueryClient.get!()
  end

  defp response_headers(conn, _opts) do
    conn
    |> put_resp_header("cache-control", Application.get_env(:halosir, :cache_control))
    |> put_resp_content_type("application/xml")
  end
end
