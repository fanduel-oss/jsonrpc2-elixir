defmodule JSONRPC2.Mixfile do
  use Mix.Project

  @version "1.1.1"

  def project do
    [
      app: :jsonrpc2,
      version: @version,
      elixir: "~> 1.3",
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      description: description(),
      package: package(),
      name: "JSONRPC2",
      docs: [
        source_ref: "v#{@version}",
        main: "readme",
        canonical: "http://hexdocs.pm/jsonrpc2",
        source_url: "https://github.com/fanduel/jsonrpc2-elixir",
        extras: ["README.md"]
      ],
      dialyzer: [plt_add_apps: [:shackle, :ranch, :plug, :hackney]],
      xref: [
        exclude: [
          Poison,
          :hackney,
          :jiffy,
          :ranch,
          :shackle,
          :shackle_pool,
          Plug.Conn,
          Plug.Adapters.Cowboy,
          Plug.Adapters.Cowboy2
        ]
      ]
    ]
  end

  def application do
    [applications: [:logger], env: [serializer: Poison]]
  end

  defp deps do
    [
      {:poison, poison_requirement(), optional: true},
      {:jiffy, "~> 0.14", optional: true},
      {:ranch, "~> 1.2", optional: true},
      {:shackle, "~> 0.3", optional: true},
      {:plug, "~> 1.3", optional: true},
      {:hackney, "~> 1.6", optional: true},
      {:cowboy, "~> 1.1 or ~> 2.4", optional: true},
      {:ex_doc, "~> 0.12", only: :dev},
      {:dialyxir, "~> 0.3", only: :dev}
    ]
  end

  {:ok, poison_requirement_version_requirement} = Version.parse_requirement("~> 1.6")
  @poison_requirement_version_requirement poison_requirement_version_requirement

  defp poison_requirement do
    System.version()
    |> Version.parse!()
    |> Version.match?(@poison_requirement_version_requirement)
    |> poison_requirement()
  end

  defp poison_requirement(true), do: "~> 4.0 or ~> 3.0 or ~> 2.0"
  defp poison_requirement(false), do: "~> 3.0 or ~> 2.0"

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp description do
    "JSON-RPC 2.0 for Elixir."
  end

  defp package do
    [
      maintainers: ["Eric Entin"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/fanduel/jsonrpc2-elixir"},
      files: ~w(mix.exs README.md LICENSE lib)
    ]
  end
end
