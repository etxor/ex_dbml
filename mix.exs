defmodule ExDbml.MixProject do
  use Mix.Project

  @version "0.1.0-dev"
  @source_url "https://github.com/etxor/ex_dbml"

  def project do
    [
      app: :ex_dbml,
      name: "ExDbml",
      version: @version,
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      dialyzer: dialyzer()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:nimble_parsec, "~> 1.4"},
      {:nimble_options, "~> 1.1"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:mix_audit, "~> 2.1", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "readme",
      # logo: "path/to/logo.png",
      source_url: @source_url,
      source_ref: "v#{@version}",
      # canonical: "http://hexdocs.pm/kaffy",
      formatters: ["html"],
      # assets: "assets",
      extras: [
        "CHANGELOG.md": [],
        LICENSE: [title: "License"],
        "README.md": [title: "Readme"]
      ]
    ]
  end

  defp dialyzer do
    [
      # Put the project-level PLT in the priv/ directory (instead of the default _build/ location)
      plt_file: {:no_warn, "priv/plts/project.plt"}
    ]
  end
end
