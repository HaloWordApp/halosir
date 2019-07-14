defmodule HaloSir.Mixfile do
  use Mix.Project

  def project do
    [
      app: :halosir,
      version: "2019.7.0",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {HaloSir.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # Phoenix & co.
      {:phoenix, "~> 1.4.0"},
      {:plug_cowboy, "~> 2.0"},
      {:jason, "~> 1.1"},

      # HTTP Client
      {:tesla, "~> 1.2"},
      {:hackney, "~> 1.14"},
      {:certifi, "~> 2.3"},

      # Metrics
      {:telemetry, "~> 0.2.0"},

      # Release
      {:distillery, "~> 2.0"},

      # Lint & Test
      {:credo, "~> 0.10", only: :dev},
      {:bypass, "~> 1.0", only: [:dev, :test]}
    ]
  end
end
