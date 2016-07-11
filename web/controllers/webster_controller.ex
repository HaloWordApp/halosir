defmodule HaloSir.WebsterController do
  @moduledoc false
  use HaloSir.Web, :controller
  alias HaloSir.Rules

  @query_url_eex "http://www.dictionaryapi.com/api/v1/references/collegiate/xml/<%= word %>?key=<%= key %>"
  @keys Application.get_env(:halosir, __MODULE__)[:keys]

  plug :webster_headers

  def query(conn, %{"word" => word}) do
    case HaloSir.RiakStore.get("webster", word) do
      {:ok, cached_obj} ->
        # Use cached result
        result = :riakc_obj.get_values(cached_obj) |> hd
        text(conn, result)
      {:error, :notfound} ->
        # Query server and cache the result
        result =
          @query_url_eex
          |> EEx.eval_string([word: URI.encode_www_form(word), key: Enum.random(@keys)])
          |> HTTPotion.get!()
          |> Map.get(:body)

        if Rules.should_cache_word?(word) do
          obj = :riakc_obj.new("webster", word, result, "text/plain")
          HaloSir.RiakStore.put(obj)
        end

        text(conn, result)
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
