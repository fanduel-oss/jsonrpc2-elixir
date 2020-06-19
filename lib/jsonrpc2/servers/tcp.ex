defmodule JSONRPC2.Servers.TCP do
  @moduledoc """
  A server for JSON-RPC 2.0 using a line-based TCP transport.
  """

  alias JSONRPC2.Servers.TCP.Protocol

  @default_timeout 1000 * 60 * 60

  @doc """
  Start a server with the given `handler` on `port` with `opts`.

  Available options:
    * `name` - a unique name that can be used to stop the server later. Defaults to the value of
      `handler`.
    * `num_acceptors` - number of acceptor processes to start. Defaults to 100.
    * `transport` - ranch transport to use. Defaults to `:ranch_tcp`.
    * `transport_opts` - ranch transport options. For `:ranch_tcp`, see
      [here](http://ninenines.eu/docs/en/ranch/1.7/manual/ranch_tcp/).
    * `timeout` - disconnect after this amount of milliseconds without a packet from a client.
      Defaults to 1 hour.
    * `line_packet` - by default, packets consist of a 4 byte header containing an unsigned integer
      in big-endian byte order specifying the number of bytes in the packet, followed by that
      number of bytes (equivalent to the
      [erlang inet packet type `4`](https://erlang.org/doc/man/inet.html#packet)). If set to
      `true`, packets will instead be terminated by line-endings, for compatibility with older
      implementations.
  """
  @spec start_listener(module, :inet.port_number(), Keyword.t()) :: {:ok, pid}
  def start_listener(handler, port, opts \\ []) do
    apply(:ranch, :start_listener, ranch_args(handler, port, opts))
  end

  @doc """
  Returns a supervisor child spec for the given `handler` on `port` with `opts`.

  Allows you to embed a server directly in your app's supervision tree, rather
  than letting Ranch handle it.

  See `start_listener/3` for available options.
  """
  @spec child_spec(module, :inet.port_number(), Keyword.t()) :: {:ok, pid}
  def child_spec(handler, port, opts \\ []) do
    apply(:ranch, :child_spec, ranch_args(handler, port, opts))
  end

  @doc """
  Stop the server with `name`.
  """
  @spec stop(atom) :: :ok | {:error, :not_found}
  def stop(name) do
    :ranch.stop_listener(name)
  end

  defp ranch_args(handler, port, opts) do
    name = Keyword.get(opts, :name, handler)
    num_acceptors = Keyword.get(opts, :num_acceptors, 100)
    transport = Keyword.get(opts, :transport, :ranch_tcp)
    transport_opts = [port: port] ++ Keyword.get(opts, :transport_opts, [])
    timeout = Keyword.get(opts, :timeout, @default_timeout)
    line_packet = !!Keyword.get(opts, :line_packet)
    protocol_opts = {handler, timeout, line_packet}

    [name, num_acceptors, transport, transport_opts, Protocol, protocol_opts]
  end
end
