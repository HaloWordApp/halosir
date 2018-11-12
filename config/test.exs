use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :halosir, HaloSir.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Use a test-specific data directory
config :halosir, HaloSir.DetsStore, data_dir: "test/data/"
