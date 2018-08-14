defmodule JSONRPC2.Servers.HTTP.PlugTest do
  use ExUnit.Case

  alias JSONRPC2.Servers.HTTP.Plug, as: JSONRPC2Plug

  test "invalid handler" do
    assert_raise(
      ArgumentError,
      "Could not load handler for JSONRPC2.Servers.HTTP.Plug, got: NotARealHandler",
      fn ->
        JSONRPC2Plug.init(handler: NotARealHandler)
      end
    )
  end
end
