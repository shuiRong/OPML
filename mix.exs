defmodule Opml.MixProject do
  use Mix.Project

  def project do
    [
      app: :opml,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Opml.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:simple_xml, "~> 1.2"},
      {:req, "~> 0.5.8"}
    ]
  end
end
