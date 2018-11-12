use Mix.Config

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# General application configuration
config :halosir,
  namespace: HaloSir

# Configures the endpoint
config :halosir, HaloSir.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "12345",
  render_errors: [view: HaloSir.ErrorView, accepts: ~w(json)]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configures Cache-Control value in response
config :halosir, cache_control: "max-age=#{3600 * 24 * 7}"

# Configures DETS tables
config :halosir, HaloSir.DetsStore,
  tables: [:youdao, :webster],
  data_dir: "data/"

# Configures Dictionary Services' api endpoints
# This is mainly for writing unit test with Bypass
config :halosir, HaloSir.YoudaoController,
  api_base: "https://fanyi.youdao.com/fanyiapi.do?type=data&doctype=json&version=1.1&"

config :halosir, HaloSir.WebsterController,
  api_eex:
    "http://www.dictionaryapi.com/api/v1/references/collegiate/xml/<%= word %>?key=<%= key %>"

import_config "#{Mix.env()}.exs"
