for line_packet <- [false, true] do
  module_name =
    if line_packet do
      JSONRPC2.TCPTest.LineTerminated
    else
      JSONRPC2.TCPTest
    end

  defmodule module_name do
    use ExUnit.Case

    setup do
      port = :rand.uniform(65535 - 1025) + 1025

      {:ok, pid} =
        JSONRPC2.Servers.TCP.start_listener(JSONRPC2.SpecHandler, port,
          name: __MODULE__,
          line_packet: unquote(line_packet)
        )

      :ok = JSONRPC2.Clients.TCP.start("localhost", port, __MODULE__, line_packet: unquote(line_packet))

      on_exit(fn ->
        ref = Process.monitor(pid)
        JSONRPC2.Clients.TCP.stop(__MODULE__)
        JSONRPC2.Servers.TCP.stop(__MODULE__)

        receive do
          {:DOWN, ^ref, :process, ^pid, :shutdown} -> :ok
        end
      end)
    end

    test "call" do
      assert JSONRPC2.Clients.TCP.call(__MODULE__, "subtract", [2, 1]) == {:ok, 1}

      assert JSONRPC2.Clients.TCP.call(__MODULE__, "subtract", [2, 1], true) == {:ok, 1}

      assert JSONRPC2.Clients.TCP.call(__MODULE__, "subtract", [2, 1], string_id: true) == {:ok, 1}

      assert JSONRPC2.Clients.TCP.call(__MODULE__, "subtract", [2, 1], timeout: 2_000) == {:ok, 1}
    end

    test "cast" do
      {:ok, request_id} = JSONRPC2.Clients.TCP.cast(__MODULE__, "subtract", [2, 1], timeout: 1_000)
      assert JSONRPC2.Clients.TCP.receive_response(request_id) == {:ok, 1}

      {:ok, request_id} = JSONRPC2.Clients.TCP.cast(__MODULE__, "subtract", [2, 1], true)
      assert JSONRPC2.Clients.TCP.receive_response(request_id) == {:ok, 1}

      {:ok, request_id} =
        JSONRPC2.Clients.TCP.cast(__MODULE__, "subtract", [2, 1], string_id: true, timeout: 2_000)

      assert JSONRPC2.Clients.TCP.receive_response(request_id) == {:ok, 1}
    end

    test "notify" do
      {:ok, _request_id} = JSONRPC2.Clients.TCP.notify(__MODULE__, "subtract", [2, 1])
    end
  end
end
