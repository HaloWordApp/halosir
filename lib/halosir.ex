defmodule HaloSir do
  @moduledoc false
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(HaloSir.Endpoint, []),
      worker(HaloSir.DetsStore, []),
    ]

    opts = [strategy: :one_for_one, name: HaloSir.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    HaloSir.Endpoint.config_change(changed, removed)
    :ok
  end
end
