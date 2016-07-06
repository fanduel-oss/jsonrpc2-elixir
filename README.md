# JSONRPC2

A JSON-RPC 2.0 server implementation for Elixir. Bring your own transport.

Check out the tests for usage examples.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `jsonrpc2` and `jiffy` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:jsonrpc2, "~> 0.1.0"}, {:jiffy, "~> 0.14"}]
    end
    ```

  2. Ensure `jsonrpc2` and `jiffy` are started before your application:

    ```elixir
    def application do
      [applications: [:jsonrpc2, :jiffy]]
    end
    ```
