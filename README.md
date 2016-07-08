[![Build Status](https://travis-ci.com/fanduel/jsonrpc2-elixir.svg?token=nqWxaCNxzZYbBCynkoqE&branch=master)](https://travis-ci.com/fanduel/jsonrpc2-elixir)

# JSONRPC2

JSON-RPC 2.0 for Elixir.

Use the included line-based TCP server/client, or bring your own transport. HTTPoison/Plug-based HTTP(S) support coming soon.

See the [`examples`](https://github.com/fanduel/jsonrpc2-elixir/tree/master/examples) directory as well as the [`JSONRPC2`](JSONRPC2.html) docs for examples.

## Installation

1. Add `jsonrpc2` and `poison` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:jsonrpc2, git: "git@github.com:fanduel/jsonrpc2-elixir.git"}, {:poison, "~> 2.2"}]
end
```

2. Ensure `jsonrpc2` and`poison` are started before your application:

```elixir
def application do
  [applications: [:jsonrpc2, :poison]]
end
```

## Serialization

Uses `poison` by default, but you can use any serializer (it doesn't even have to be JSON, technically).

A serializer for `jiffy` is included as `JSONRPC2.Serializers.Jiffy`.

To use a different serializer you must configure it in your Mix config. For the `jiffy` serializer:

```elixir
config :jsonrpc2, :serializer, JSONRPC2.Serializers.Jiffy
```

If you are going to use the `jiffy` serializer, you must add it to your deps and applications instead of `poison`:

```elixir
def deps do
  [{:jsonrpc2, git: "git@github.com:fanduel/jsonrpc2-elixir.git"}, {:jiffy, "~> 0.14"}]
end
```

```elixir
def application do
  [applications: [..., :jiffy]]
end
```

If you use your own serializer, you do not (necessarily) need to add `poison` or `jiffy` to your deps/apps.

## TCP server

If you plan to use the TCP server, you also need to add `ranch` to your deps/apps.

```elixir
def deps do
  [..., {:ranch, "~> 1.2"}]
end
```

```elixir
def application do
  [applications: [..., :ranch]]
end
```

## TCP client

If you plan to use the TCP client, you also need to add `shackle` to your deps/apps.

```elixir
def deps do
  [..., {:shackle, github: "lpgauth/shackle", tag: "0.3.1"}]
end
```

```elixir
def application do
  [applications: [..., :shackle]]
end
```
