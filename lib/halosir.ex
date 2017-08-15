defmodule HaloSir do
  @moduledoc false
  use Application

  alias HaloSir.{DetsStore, Endpoint, MetricStore}

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(DetsStore, []),
      supervisor(Endpoint, []),
      supervisor(MetricStore, []),
    ]

    opts = [strategy: :one_for_one, name: HaloSir.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end
end
