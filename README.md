[![Build Status](https://travis-ci.com/fanduel/jsonrpc2-elixir.svg?token=nqWxaCNxzZYbBCynkoqE&branch=master)](https://travis-ci.com/fanduel/jsonrpc2-elixir)

# JSONRPC2

A JSON-RPC 2.0 request/handler implementation for Elixir. Bring your own transport.

Check out the tests for usage examples.

## Serialization

Uses jiffy by default, but take a look at `JSONRPC2.Serializers.JiffySerializer` for an example of how to implement your own serializer, then configure your serializer like so:

```elixir
config :jsonrpc2, :serializer, MyApp.MyJSONRPC2Serializer
```

If you use your own serializer, you do not need to add `jiffy` to your deps/apps.

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
