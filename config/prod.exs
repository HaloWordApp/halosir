use Mix.Config

config :halosir, HaloSir.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: {:system, "PORT"}],
  cache_static_manifest: "priv/static/manifest.json"

config :logger, level: :error

import_config "prod.secret.exs"
