defmodule JSONRPC2.LSPTest do
  use ExUnit.Case, async: true
  alias JSONRPC2.Clients.TCP, as: TCPClient
  alias JSONRPC2.Serializers.LSP

  setup do
    port = :rand.uniform(65535 - 1000) + 1000

    {:ok, pid} = JSONRPC2.Servers.TCP.start_listener(JSONRPC2.LSPHandler, port, name: __MODULE__)

    :ok = TCPClient.start("localhost", port, __MODULE__)

    on_exit fn ->
      ref = Process.monitor(pid)
      TCPClient.stop(__MODULE__)
      JSONRPC2.Servers.TCP.stop(__MODULE__)
      receive do
        {:DOWN, ^ref, :process, ^pid, :shutdown} -> :ok
      end
    end
  end

  setup_all do
    {:ok, challenges: [
    ["alpha", "beta", "gamma"],
    [1,2,3],
    %{"c" => 3, "b" => 2, "x" => 1},
    "stuff",
    55,
    0.253,
    true,
    false,
    nil,
    [],
    %{},
    %{"array" => [1,2,3],
      "nil" => nil,
      "string" => "sanity",
      "number" => 12,
      "another object" => %{
        "array" => [],
        "string" => "five",
        "number" => 5,
        "nil" => nil
      }
    }
  ]}
  end

  test "it should be able to serialize and deserialize values", state do
    Enum.each(state[:challenges], fn challenge ->
      serialize_deserialize_test(challenge)
    end)
  end

  defp serialize_deserialize_test(value) do
    {:ok, encoded} = LSP.encode(value)
    {:ok, decoded} = LSP.decode(encoded)
    assert(value == decoded)
  end
end
