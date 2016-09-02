defmodule JSONRPC2.Client.TCPTest do
  use ExUnit.Case, async: true

  test "id_and_response work with int" do
    raw_response = %{"jsonrpc" => "2.0", "result" => "{'Test': 'int'}", "id"=>123}
    assert raw_response
      |> JSONRPC2.Response.id_and_response == {:ok, {123, {:ok, "{'Test': 'int'}"}}}
  end

  test "id_and_response work with string" do
    raw_response = %{"jsonrpc" => "2.0", "result" => "{'Test': 'string'}", "id"=>"987"}
    assert raw_response
      |> JSONRPC2.Response.id_and_response == {:ok, {987, {:ok, "{'Test': 'string'}"}}}
  end

  test "id_and_response work with bad string" do
    raw_response = %{"jsonrpc" => "2.0", "result" => "{'Test': 'bad string'}", "id"=>"Foo"}
    assert raw_response
      |> JSONRPC2.Response.id_and_response == {:error, {:invalid_response, raw_response}}
  end
end
