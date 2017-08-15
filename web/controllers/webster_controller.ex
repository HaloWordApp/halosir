defmodule HaloSir.WebsterController do
  @moduledoc false
  use HaloSir.Web, :controller
  alias HaloSir.{Rules, DetsStore, MetricStore}

  plug :webster_headers

  def query(conn, %{"word" => word}) do
    case DetsStore.get(:webster, word) do
      {:ok, cached_result} ->
        DetsStore.incr(:webster, word)
        MetricStore.dict_query(:webster, true, word)
        text(conn, cached_result)
      {:error, :notfound} ->
        resp = query_webster(word)

        if resp.status_code != 200 do
          MetricStore.failed_query(:webster, word)
          resp(conn, resp.status_code, resp.body)
        else
          result = Map.get(resp, :body)
          MetricStore.dict_query(:webster, false, word)

          if Rules.should_cache_word?(word) do
            DetsStore.put(:webster, word, result)
            MetricStore.dets_cache(:webster, word)
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
    |> HTTPotion.get!()
  end

  defp webster_headers(conn, _opts) do
    conn
    |> put_resp_header("cache-control", Application.get_env(:halosir, :cache_control))
    |> put_resp_content_type("application/xml")
  end
end
