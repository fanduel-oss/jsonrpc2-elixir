defmodule JSONRPC2.HTTPTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, pid} = JSONRPC2.Servers.HTTP.http(JSONRPC2.SpecHandler)

    on_exit fn ->
      ref = Process.monitor(pid)
      JSONRPC2.Servers.HTTP.shutdown(JSONRPC2.SpecHandler.HTTP)
      receive do
          {:DOWN, ^ref, :process, ^pid, :shutdown} -> :ok
      end
    end
  end

  test "call" do
    assert JSONRPC2.Clients.HTTP.call("http://localhost:4000/", "subtract", [2, 1]) == {:ok, 1}
  end

  test "notify" do
    assert JSONRPC2.Clients.HTTP.notify("http://localhost:4000/", "subtract", [2, 1]) == :ok
  end

  test "batch" do
    batch = [{"subtract", [2, 1]}, {"subtract", [2, 1], 0}, {"subtract", [2, 2], 1}]
    expected = [ok: {0, {:ok, 1}}, ok: {1, {:ok, 0}}]
    assert JSONRPC2.Clients.HTTP.batch("http://localhost:4000/", batch) == expected
  end

end
