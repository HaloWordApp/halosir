use Mix.Config

config :bypass, adapter: Plug.Cowboy

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :halosir, HaloSirWeb.Endpoint,
  http: [port: 4001],
  server: false

config :phoenix, :stacktrace_depth, 40

# Print only warnings and errors during test
config :logger, level: :warn

# Use a test-specific data directory
config :halosir, HaloSir.DetsStore, data_dir: "test/data/"
