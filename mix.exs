defmodule JSONRPC2.Mixfile do
  use Mix.Project

  @version "2.0.0"

  def project do
    [
      app: :jsonrpc2,
      version: @version,
      elixir: "~> 1.8",
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
          Plug.Cowboy
        ]
      ]
    ]
  end

  def application do
    [extra_applications: [:logger], env: [serializer: Jason]]
  end

  defp deps do
    [
      {:jason, "~> 1.0", optional: true},
      {:poison, "~> 4.0 or ~> 3.0 or ~> 2.0", optional: true},
      {:jiffy, "~> 1.0 or ~> 0.14", optional: true},
      {:shackle, "~> 0.3", optional: true},
      {:ranch, "~> 1.2", optional: true},
      {:hackney, "~> 1.6", optional: true},
      {:plug, "~> 1.3", optional: true},
      {:plug_cowboy, "~> 2.0", optional: true},
      {:cowboy, "~> 2.4 or ~> 1.1", optional: true},
      {:ex_doc, "~> 0.20", only: :dev}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp description do
    "JSON-RPC 2.0 for Elixir."
  end

  defp package do
    [
      licenses: ["Apache 2.0"],
      links: %{
        "Important v2.0 Upgrade Information" => "https://hexdocs.pm/jsonrpc2/readme.html#v2-0-upgrade",
        "GitHub" => "https://github.com/fanduel/jsonrpc2-elixir"
      },
      files: ~w(mix.exs README.md LICENSE lib)
    ]
  end
end
