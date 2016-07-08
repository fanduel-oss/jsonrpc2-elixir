defmodule JSONRPC2.Serializers.Jiffy do
  @moduledoc false

  def decode(json) do
    try do
      {:ok, :jiffy.decode(json, [:return_maps, :use_nil])}
    catch
      kind, payload -> {:error, {kind, payload}}
    end
  end

  def encode(json) do
    try do
      {:ok, :jiffy.encode(json, [:use_nil])}
    catch
      kind, payload -> {:error, {kind, payload}}
    end
  end
end
