defmodule HaloSir.Mixfile do
  use Mix.Project

  def project do
    [
      app: :halosir,
      version: "2.0.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {HaloSir.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_), do: ["lib", "web"]

  defp deps do
    [
      {:phoenix, "~> 1.4.0"},
      {:plug_cowboy, "~> 2.0"},
      {:tesla, "~> 1.2"},
      {:hackney, "~> 1.14.0"},
      {:jason, "~> 1.1"},
      {:credo, "~> 0.10", only: :dev},
      {:bypass, "~> 0.8", only: [:dev, :test]}
    ]
  end

  defp aliases() do
    [
      test: ["cleanup_testdata", "test"]
    ]
  end
end
