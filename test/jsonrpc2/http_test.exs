defmodule JSONRPC2.HTTPTest do
  use ExUnit.Case, async: true

  setup do
    port = :rand.uniform(65535 - 1025) + 1025
    {:ok, pid} = JSONRPC2.Servers.HTTP.http(JSONRPC2.SpecHandler, port: port)

    on_exit(fn ->
      ref = Process.monitor(pid)
      JSONRPC2.Servers.HTTP.shutdown(JSONRPC2.SpecHandler.HTTP)

      receive do
        {:DOWN, ^ref, :process, ^pid, :shutdown} -> :ok
      end
    end)

    {:ok, %{port: port}}
  end

  test "call", %{port: port} do
    assert JSONRPC2.Clients.HTTP.call("http://localhost:#{port}/", "subtract", [2, 1]) == {:ok, 1}
  end

  test "call with custom id", %{port: port} do
    expected = {:ok, 1}
    actual = JSONRPC2.Clients.HTTP.call("http://localhost:#{port}/", "subtract", [2, 1], [], :post, [], 123)
    assert actual == expected
  end

  test "notify", %{port: port} do
    assert JSONRPC2.Clients.HTTP.notify("http://localhost:#{port}/", "subtract", [2, 1]) == :ok
  end

  test "batch", %{port: port} do
    batch = [{"subtract", [2, 1]}, {"subtract", [2, 1], 0}, {"subtract", [2, 2], 1}]
    expected = [ok: {0, {:ok, 1}}, ok: {1, {:ok, 0}}]
    assert JSONRPC2.Clients.HTTP.batch("http://localhost:#{port}/", batch) == expected
  end

  test "call text/plain", %{port: port} do
    assert JSONRPC2.Clients.HTTP.call("http://localhost:#{port}/", "subtract", [2, 1], [
             {"content-type", "text/plain"}
           ]) == {:ok, 1}
  end

  test "notify text/plain", %{port: port} do
    assert JSONRPC2.Clients.HTTP.notify("http://localhost:#{port}/", "subtract", [2, 1], [
             {"content-type", "text/plain"}
           ]) == :ok
  end

  test "batch text/plain", %{port: port} do
    batch = [{"subtract", [2, 1]}, {"subtract", [2, 1], 0}, {"subtract", [2, 2], 1}]
    expected = [ok: {0, {:ok, 1}}, ok: {1, {:ok, 0}}]

    assert JSONRPC2.Clients.HTTP.batch("http://localhost:#{port}/", batch, [{"content-type", "text/plain"}]) ==
             expected
  end

  test "bad call", %{port: port} do
    assert {:error, {:http_request_failed, 404, _headers, {:ok, ""}}} =
             JSONRPC2.Clients.HTTP.call(
               "http://localhost:#{port}/",
               "subtract",
               [2, 1],
               [
                 {"content-type", "application/json"}
               ],
               :get
             )
  end
end
