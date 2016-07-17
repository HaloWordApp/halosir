use Mix.Config

config :halosir, HaloSir.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: {:system, "PORT"}],
  cache_static_manifest: "priv/static/manifest.json"

# Do not print debug messages in production
config :logger, level: :info

import_config "prod.secret.exs"
