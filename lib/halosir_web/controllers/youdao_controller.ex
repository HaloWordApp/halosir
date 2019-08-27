defmodule HaloSirWeb.YoudaoController do
  @moduledoc false
  use HaloSirWeb, :controller
  @behaviour HaloSirWeb.QueryController

  plug :response_headers

  def query(conn, %{"word" => word}) do
    HaloSirWeb.QueryController.query_word(conn, __MODULE__, word)
  end

  @impl true
  def dict_type(), do: :youdao

  @impl true
  def valid_response?(resp) do
    case Jason.decode(resp.body) do
      {:ok, r} ->
        ec = Map.get(r, "errorCode", 0)
        ec == 0
      _ -> false
    end
  end

  @impl true
  def query_url(word) do
    config = Application.get_env(:halosir, __MODULE__)

    if Keyword.has_key?(config, :proxy) do
      encoded_word =
        word
        |> String.split()
        |> Enum.map(&URI.encode_www_form/1)
        |> Enum.join(" ")

      config[:proxy] <> encoded_word
    else
      args =
        config
        |> Keyword.delete(:api_base)
        |> Keyword.merge(q: word)
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
