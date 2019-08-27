defmodule HaloSirWeb.QueryController do
  @moduledoc """
  A Phoenix controller implementing this behaviour can call `query_word` to
  reuse the pipeline for caching, metrics and more.
  """

  @doc """
  Defines the query URL to use if cached result not available
  """
  @callback query_url(word :: String.t()) :: String.t()

  @doc """
  Defines the dictionary type (`webster`, `youdao` etc..)
  """
  @callback dict_type() :: atom()

  @doc """
  Validate the result from remote servers, because some have
  "custom" error reporting than HTTP response code
  """
  @callback valid_response?(resp :: Tesla.Env.t()) :: boolean()

  import Plug.Conn
  import Phoenix.Controller, only: [text: 2]
  alias HaloSir.{Rules, DetsStore, QueryClient}

  def query_word(conn, controller_module, word) do
    type = controller_module.dict_type()

    case DetsStore.get(type, word) do
      {:ok, cached_result} ->
        Telemetry.execute([:halosir, type, :dets_get], 1, %{cached?: true})
        DetsStore.incr(type, word)
        text(conn, cached_result)

      {:error, :notfound} ->
        Telemetry.execute([:halosir, type, :dets_get], 1, %{cached?: false})

        resp =
          word
          |> controller_module.query_url()
          |> QueryClient.get!()

        if resp.status != 200 do
          Telemetry.execute([:halosir, type, :query], 1, %{success?: false})
          resp(conn, 502, "upstream failure")
        else
          Telemetry.execute([:halosir, type, :query], 1, %{success?: true})

          result = Map.get(resp, :body)

          if Rules.should_cache_word?(word) && controller_module.valid_response?(resp) do
            DetsStore.put(type, word, result)
            Telemetry.execute([:halosir, type, :dets_put], 1)
          end

          text(conn, result)
        end

      _ ->
        halt(conn)
    end
  end
end
