defmodule GCS.MixProject do
  use Mix.Project

  def project do
    [
      app: :gcs,
      version: "0.0.1",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      source_url: "github"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.5"},
      {:goth, "~> 1.1"},
      {:ex_doc, "~> 0.21.2", only: :dev, runtime: false},
      {:jason, "~> 1.0"}
    ]
  end

  defp package do
    [
      name: "gcs",
      description: "A simple library to interact with Google Cloud Storage",
      # These are the default files included in the package
      files: ~w(lib mix.exs README.md LICENSE CHANGELOG.md),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/jdrakes/gcs"}
    ]
  end
end
