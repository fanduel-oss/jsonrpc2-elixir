[![Build Status](https://travis-ci.org/fanduel/jsonrpc2-elixir.svg?branch=master)](https://travis-ci.org/fanduel/jsonrpc2-elixir)

# JSONRPC2

JSON-RPC 2.0 for Elixir.

Use the included line-based TCP/TLS server/client, JSON-in-the-body HTTP(S) server/client, or bring your own transport.

See the [`examples`](https://github.com/fanduel/jsonrpc2-elixir/tree/master/examples) directory as well as the [`JSONRPC2`](https://hexdocs.pm/jsonrpc2/JSONRPC2.html) docs for examples.

## Installation

Add `jsonrpc2` and `jason` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:jsonrpc2, "~> 1.0"}, {:jason, "~> 1.0"}]
end
```

## Serialization

Uses `jason` by default, but you can use any serializer (it doesn't even have to be JSON, technically).

A serializer for `jiffy` is included as `JSONRPC2.Serializers.Jiffy`, and legacy users can select `Poison` if they have included it as a dependency.

To use a different serializer you must configure it in your Mix config. For the `jiffy` serializer:

```elixir
config :jsonrpc2, :serializer, JSONRPC2.Serializers.Jiffy
```

If you are going to use the `jiffy` serializer, you must add it to your deps instead of `jason`:

```elixir
def deps do
  [..., {:jiffy, "~> 1.0"}]
end
```

If you use your own serializer, you do not (necessarily) need to add `jason` or `jiffy` to your deps.

## TCP/TLS server

If you plan to use the TCP/TLS server, you also need to add `ranch` to your deps.

```elixir
def deps do
  [..., {:ranch, "~> 1.7"}]
end
```

## TCP/TLS client

If you plan to use the TCP/TLS client, you also need to add `shackle` to your deps/apps.

```elixir
def deps do
  [..., {:shackle, "~> 0.5"}]
end
```

## HTTP(S) server

If you plan to use the HTTP(S) server, you also need to add `plug`, `cowboy`, and `plug_cowboy` to your deps.

```elixir
def deps do
  [..., {:plug, "~> 1.8"}, {:cowboy, "~> 2.6"}, {:plug_cowboy, "~> 2.0}]
end
```

## HTTP(S) client

If you plan to use the HTTP(S) client, you also need to add `hackney` to your deps.

```elixir
def deps do
  [..., {:hackney, "~> 1.15"}]
end
```
