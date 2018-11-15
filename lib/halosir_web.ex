defmodule HaloSirWeb do
  @moduledoc false
  def controller do
    quote do
      use Phoenix.Controller, namespace: HaloSirWeb

      import Plug.Conn
      alias HaloSirWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "lib/halosir_web/templates", namespace: HaloSirWeb

      alias HaloSirWeb.Router.Helpers, as: Routes
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
