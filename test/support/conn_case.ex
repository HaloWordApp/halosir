defmodule HaloSirWeb.ConnCase do
  @moduledoc false
  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      alias HaloSirWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint HaloSirWeb.Endpoint
    end
  end

  setup _tags do
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
