defmodule JSONRPC2.Servers.HTTP do
  @moduledoc """
  An HTTP server which responds to POSTed JSON-RPC 2.0 in the request body.

  This server will respond to all requests on the given port. If you wish to mount a JSON-RPC 2.0
  handler within a Plug-based web app (such as Phoenix), please see `JSONRPC2.Servers.HTTP.Plug`.
  """

  alias JSONRPC2.Servers.HTTP.Plug, as: JSONRPC2Plug

  @doc """
  Returns a supervisor child spec for the given `handler` via `scheme` with `cowboy_opts`.

  Allows you to embed a server directly in your app's supervision tree, rather than letting
  Plug/Cowboy handle it.

  Please see the docs for [Plug](https://hexdocs.pm/plug/Plug.Adapters.Cowboy.html) for the values
  which are allowed in `cowboy_opts`.

  If the server `ref` is not set in `cowboy_opts`, `handler.HTTP` or `handler.HTTPS` is the default.
  """
  @spec child_spec(:http | :https, module, list) :: Supervisor.Spec.spec()
  def child_spec(scheme, handler, cowboy_opts \\ []) do
    cowboy_opts = cowboy_opts ++ [ref: ref(scheme, handler)]
    cowboy_adapter().child_spec(scheme, JSONRPC2Plug, handler, cowboy_opts)
  end

  @doc """
  Starts an HTTP server for the given `handler` with `cowboy_opts`.

  Please see the docs for [Plug](https://hexdocs.pm/plug/Plug.Adapters.Cowboy.html) for the values
  which are allowed in `cowboy_opts`.

  If the server `ref` is not set in `cowboy_opts`, `handler.HTTP` is the default.
  """
  @spec http(module, list) :: {:ok, pid} | {:error, term}
  def http(handler, cowboy_opts \\ []) do
    cowboy_opts = cowboy_opts ++ [ref: ref(:http, handler)]
    cowboy_adapter().http(JSONRPC2Plug, handler, cowboy_opts)
  end

  @doc """
  Starts an HTTPS server for the given `handler` with `cowboy_opts`.

  Please see the docs for [Plug](https://hexdocs.pm/plug/Plug.Adapters.Cowboy.html) for the values
  which are allowed in `cowboy_opts`. In addition to the normal `cowboy_opts`, this function also
  accepts the same extra SSL-related options as
  [Plug.Adapters.Cowboy.https/3](https://hexdocs.pm/plug/Plug.Adapters.Cowboy.html#https/3).

  If the server `ref` is not set in `cowboy_opts`, `handler.HTTPS` is the default.
  """
  @spec https(module, list) :: {:ok, pid} | {:error, term}
  def https(handler, cowboy_opts \\ []) do
    cowboy_opts = cowboy_opts ++ [ref: ref(:https, handler)]
    cowboy_adapter().https(JSONRPC2Plug, handler, cowboy_opts)
  end

  defp ref(scheme, handler) do
    case scheme do
      :http -> [handler, HTTP]
      :https -> [handler, HTTPS]
    end
    |> Module.concat()
  end

  @doc """
  Shut down an existing server with given `ref`.
  """
  @spec shutdown(atom) :: :ok | {:error, :not_found}
  def shutdown(ref) do
    cowboy_adapter().shutdown(ref)
  end

  defp cowboy_adapter() do
    cowboy_spec =
      Application.loaded_applications()
      |> List.keyfind(:cowboy, 0)

    if cowboy_spec do
      cowboy_spec
      |> elem(2)
      |> List.to_string()
      |> Version.parse!()
      |> Version.match?("~> 2.0")
      |> case do
        true -> Plug.Adapters.Cowboy2
        false -> Plug.Adapters.Cowboy
      end
    else
      :ok = Application.load(:cowboy)

      cowboy_adapter()
    end
  end
end
