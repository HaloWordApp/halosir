defmodule HaloSir.QueryClient do
  @moduledoc false
  use Tesla

  adapter Tesla.Adapter.Hackney, ssl: [cacertfile: :certifi.cacertfile()]
end
