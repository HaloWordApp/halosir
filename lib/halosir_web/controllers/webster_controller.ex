defmodule HaloSirWeb.WebsterController do
  @moduledoc false
  use HaloSirWeb, :controller
  @behaviour HaloSirWeb.QueryController

  plug :response_headers

  def query(conn, %{"word" => word}) do
    HaloSirWeb.QueryController.query_word(conn, __MODULE__, word)
  end

  @impl true
  def dict_type(), do: :webster

  @impl true
  def valid_response?(_), do: true

  @impl true
  def query_url(word) do
    key =
      Application.get_env(:halosir, __MODULE__)[:keys]
      |> Enum.random()

    Application.get_env(:halosir, __MODULE__)[:api_eex]
    |> EEx.eval_string(word: URI.encode_www_form(word), key: key)
  end

  defp response_headers(conn, _opts) do
    conn
    |> put_resp_header("cache-control", Application.get_env(:halosir, :cache_control))
    |> put_resp_content_type("application/xml")
  end
end
