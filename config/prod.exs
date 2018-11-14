use Mix.Config

config :halosir, HaloSirWeb.Endpoint,
  http: [
    ip: {127, 0, 0, 1},
    port: {:system, "PORT"}
  ]

config :logger, level: :error

import_config "prod.secret.exs"
