defmodule HaloSir.WebsterController do
  @moduledoc false
  use HaloSir.Web, :controller
  alias HaloSir.{Rules, DetsStore, MetricStore}

  plug :webster_headers

  def query(conn, %{"word" => word}) do
    case DetsStore.get(:webster, word) do
      {:ok, cached_result} ->
        DetsStore.incr(:webster, word)

        MetricStore.write("dict_query", [dict: "webster", cached: true], [word: word])

        text(conn, cached_result)
      {:error, :notfound} ->
        key =
          Application.get_env(:halosir, __MODULE__)[:keys]
          |> Enum.random()

        resp =
          Application.get_env(:halosir, __MODULE__)[:api_eex]
          |> EEx.eval_string([word: URI.encode_www_form(word), key: key])
          |> HTTPotion.get!()

        if resp.status_code != 200 do
          resp(conn, resp.status_code, resp.body)
        else
          result = Map.get(resp, :body)

          MetricStore.write("dict_query", [dict: "webster", cached: false], [word: word])

          if Rules.should_cache_word?(word) do
            DetsStore.put(:webster, word, result)

            MetricStore.write("dets_cache", [dict: "webster"], [word: word])
          end

          text(conn, result)
        end
      _ ->
        halt(conn)
    end
  end

  defp webster_headers(conn, _opts) do
    conn
    |> put_resp_header("cache-control", Application.get_env(:halosir, :cache_control))
    |> put_resp_content_type("application/xml")
  end
end
