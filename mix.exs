defmodule Nesto.MixProject do
  use Mix.Project

  def project do
    [
      app: :nesto,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),


     # Docs
      name: "Nesto",
      source_url: "https://github.com/seeken/nesto",
      homepage_url: "https://github.com/seeken/nesto",
      docs: [
        main: "Nesto", # The main page in the docs
        #logo: "path/to/logo.png",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix, "~> 1.7"},
      #{:phoenix_html_helpers, "~> 1.0"},
      {:phoenix_live_view, "~> 0.20"},
      {:petal_components, "~> 1.0"},

      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
