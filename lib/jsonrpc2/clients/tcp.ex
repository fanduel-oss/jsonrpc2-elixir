defmodule JSONRPC2.Clients.TCP do
  @moduledoc """
  A client for JSON-RPC 2.0 using a line-based TCP transport.
  """

  alias JSONRPC2.Clients.TCP.Protocol

  @type host :: binary | :inet.socket_address | :inet.hostname

  @type request_id :: any

  @doc """
  Start a client pool named `name`, connected to `host` at `port`.

  You can optionally pass `client_opts`, detailed
  [here](https://github.com/lpgauth/shackle#client_options), as well as `pool_opts`, detailed
  [here](https://github.com/lpgauth/shackle#pool_options).
  """
  @spec start(host, :inet.port_number, atom, Keyword.t, Keyword.t) :: :ok
  def start(host, port, name, client_opts \\ [], pool_opts \\ []) do
    host = if is_binary(host), do: to_charlist(host), else: host

    ip =
      case host do
        host when is_list(host) ->
          case :inet.parse_address(host) do
            {:ok, ip} -> ip
            {:error, :einval} -> host
          end
        host -> host
      end

    client_opts = [ip: ip, port: port, socket_options: [:binary, packet: :line]] ++ client_opts
    :shackle_pool.start(name, Protocol, client_opts, pool_opts)
  end

  @doc """
  Stop the client pool with name `name`.
  """
  @spec stop(atom) :: :ok | {:error, :shackle_not_started | :pool_not_started}
  def stop(name) do
    :shackle_pool.stop(name)
  end

  @doc """
  Call the given `method` with `params` using the client pool named `name`.
  """
  @spec call(atom, JSONRPC2.method, JSONRPC2.params) :: {:ok, any} | {:error, any}
  def call(name, method, params) do
    :shackle.call(name, {:call, method, params})
  end

  @doc """
  Asynchronously call the given `method` with `params` using the client pool named `name`.

  Use `receive_response/1` with the `request_id` to get the response.
  """
  @spec cast(atom, JSONRPC2.method, JSONRPC2.params) :: {:ok, request_id} | {:error, :backlog_full}
  def cast(name, method, params) do
    :shackle.cast(name, {:call, method, params})
  end

  @doc """
  Receive the response for a previous `cast/3` which returned a `request_id`.
  """
  @spec receive_response(request_id) :: {:ok, any} | {:error, any}
  def receive_response(request_id) do
    :shackle.receive_response(request_id)
  end

  @doc """
  Send a notification with the given `method` and `params` using the client pool named `name`.

  This function returns a `request_id`, but it should not be used with `receive_response/1`.
  """
  @spec notify(atom, JSONRPC2.method, JSONRPC2.params) ::
    {:ok, request_id} | {:error, :backlog_full}
  def notify(name, method, params) do
    :shackle.cast(name, {:notify, method, params})
  end
end
