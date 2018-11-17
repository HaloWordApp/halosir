use Mix.Releases.Config,
    default_release: :default,
    default_environment: Mix.env()

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"prod-secret"
  set vm_args: "rel/vm.args"
  set config_providers: [
    {Mix.Releases.Config.Providers.Elixir, ["${RELEASE_ROOT_DIR}/config/secret.exs"]}
  ]
  set overlays: [
    {:mkdir, "config"},
    {:mkdir, "data"}
  ]
end

release :halosir do
  set version: current_version(:halosir)
  set applications: [
    :runtime_tools
  ]
end
