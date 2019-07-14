defmodule HaloSir.Application do
  @moduledoc false
  use Application

  alias HaloSir.DetsStore
  alias HaloSirWeb.Endpoint

  def start(_type, _args) do
    children = [
      DetsStore,
      Endpoint
    ]

    opts = [strategy: :one_for_one, name: HaloSir.RootSup]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end
end
