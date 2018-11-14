defmodule HaloSir.QueryClient do
  use Tesla

  adapter Tesla.Adapter.Hackney, ssl: [cacertfile: :certifi.cacertfile()]
end
