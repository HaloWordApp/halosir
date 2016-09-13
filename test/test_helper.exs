ExUnit.start

# Setup meck for Fluxter, ignore metrics gathering code
:meck.new(HaloSir.MetricStore)
:meck.expect(HaloSir.MetricStore, :write, fn(_, _, _) -> :ok end)

Application.ensure_all_started(:bypass)
