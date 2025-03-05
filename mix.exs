defmodule Opml.MixProject do
  use Mix.Project

  def project do
    [
      app: :opml,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Opml",
      description: description(),
      source_url: "https://github.com/shuiRong/opml",
      package: package()
    ]
  end

  defp description() do
    "A Elixir library for parsing OPML content from URLs or direct XML content. Outputs programmer-friendly, parsed JSON data structures."
  end

  defp package() do
    [
      name: "opml",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/shuiRong/opml"}
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
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:simple_xml, "~> 1.2"},
      {:req, "~> 0.5.8"}
    ]
  end
end
