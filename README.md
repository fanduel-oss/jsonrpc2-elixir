[![Build Status](https://travis-ci.org/fanduel/jsonrpc2-elixir.svg?branch=master)](https://travis-ci.org/fanduel/jsonrpc2-elixir)

# JSONRPC2

JSON-RPC 2.0 for Elixir.

Use the included TCP/TLS server/client, JSON-in-the-body HTTP(S) server/client, or bring your own transport.

See the [`examples`](https://github.com/fanduel/jsonrpc2-elixir/tree/master/examples) directory as well as the [`JSONRPC2`](https://hexdocs.pm/jsonrpc2/JSONRPC2.html) docs for examples.

To install, add `jsonrpc2` and `jason` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:jsonrpc2, "~> 2.0"}, {:jason, "~> 1.0"}]
end
```

## **v2.0 Upgrade**

### tl;dr

**The TCP/TLS server/client default packet format has changed in v2.0, causing backwards incompatibility.**

If your existing servers/clients are working fine in `line_packet` mode, there is no need to change to the new packet format.

**However, if you wish to upgrade existing servers/clients to v2.0 safely, you must now pass the `line_packet: true` option.**

Here are some examples of adding the option for both server and client:

```elixir
# Server option should be added to `opts`
JSONRPC2.Servers.TCP.start_listener(handler, port, name: name, line_packet: true)
JSONRPC2.Servers.TCP.child_spec(handler, port, name: name, line_packet: true)

# Client option should be added to `client_opts`
JSONRPC2.Clients.TCP.start(host, port, name, line_packet: true)
```

### Why?

The line-terminated packet format caused the size of the packet to be limited by the size of the socket's receive buffer, causing difficult to diagnose errors when the packet size passed the limit.

The only downside of the new approach is a 4-byte overhead due to a new header indicating the size of the rest of the packet. 

In light of the fact that the smallest possible JSON-RPC 2.0 request is approximately 50 bytes, I have decided to make this format the new default in an attempt to follow the principle of least surprise.

### What if I want to switch to the new packet format, and uptime is a concern?

Here's an example approach:

1. Update to v2.0, add `line_packet: true`, and deploy.
2. Add a new server listener for each existing one, on a different port, without `line_packet: true`, and deploy.
3. Update clients to use the new port, remove `line_packet: true`, and deploy.
4. Remove the original server listener for each one you created, and deploy.

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
  [..., {:plug, "~> 1.8"}, {:cowboy, "~> 2.6"}, {:plug_cowboy, "~> 2.0"}]
end
```

## HTTP(S) client

If you plan to use the HTTP(S) client, you also need to add `hackney` to your deps.

```elixir
def deps do
  [..., {:hackney, "~> 1.15"}]
end
```
