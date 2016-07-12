defmodule JSONRPC2.Clients.TCPTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, pid} = JSONRPC2.Servers.TCP.start_listener(JSONRPC2.SpecHandler, 8888, name: __MODULE__)

    :ok = JSONRPC2.Clients.TCP.start("localhost", 8888, __MODULE__)

    on_exit fn ->
      ref = Process.monitor(pid)
      JSONRPC2.Clients.TCP.stop(__MODULE__)
      JSONRPC2.Servers.TCP.stop(__MODULE__)
      receive do
        {:DOWN, ^ref, :process, ^pid, :shutdown} -> :ok
      end
    end
  end

  test "call" do
    assert JSONRPC2.Clients.TCP.call(__MODULE__, "subtract", [2, 1]) == {:ok, 1}
  end

  test "cast" do
    {:ok, request_id} = JSONRPC2.Clients.TCP.cast(__MODULE__, "subtract", [2, 1])
    assert JSONRPC2.Clients.TCP.receive_response(request_id) == {:ok, 1}
  end

  test "notify" do
    {:ok, request_id} = JSONRPC2.Clients.TCP.notify(__MODULE__, "subtract", [2, 1])
    assert JSONRPC2.Clients.TCP.receive_response(request_id) == {:error, :timeout}
  end
end
