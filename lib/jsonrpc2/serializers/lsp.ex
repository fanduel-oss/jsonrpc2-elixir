defmodule JSONRPC2.Serializers.SerializeError do
  @moduledoc false
  @type t :: %__MODULE__{pos: integer, value: String.t}

  defexception pos: nil, value: nil

  def message(%{value: nil, pos: pos}) do
    "Unexpected end of input at position #{pos}"
  end

  def message(%{value: value, pos: pos}) do
    start = pos - String.length(value)
    "Cannot parse value at position #{start}: #{inspect(value)}"
  end

end

defmodule JSONRPC2.Serializers.LSP do
  @moduledoc """
  The Language Server Protocol (LSP) serializer can be used to encode and decode
  messages sent per the Languagse Server Protocol specification. For further info, See:
  https://github.com/Microsoft/language-server-protocol/blob/master/protocol.md#base-protocol
  """

  alias JSONRPC2.Serializers.SerializeError

  def decode(packet) do
    try do
      {:ok, read_packet!(packet)}
    catch
      kind, payload -> {:error, {kind, payload}}
    end
  end

  def encode(packet) do
    try do
      body = Poison.encode!(packet) <> "\r\n\r\n"
      {:ok, "Content-Length: #{byte_size(body)}\r\n\r\n" <> body}
    catch
      kind, payload -> {:error, {kind, payload}}
    end
  end

  defp read_packet!(packet, headers \\ %{})
  defp read_packet!("", _headers), do: ""
  defp read_packet!(packet, headers)
  when is_bitstring(packet) do
    read_packet!(String.split(packet, "\r\n"), headers)
  end
  defp read_packet!(packet, headers)
  when is_list(packet) do
    case packet do
      ["", body, "", ""] ->
        read_body!(body <> "\r\n\r\n", headers)
      [header | rest] ->
        [key, value] = String.split(header, ": ")
        read_packet!(rest, Map.put(headers, key, value))
      _ ->
        ""
    end
  end

  defp read_body!(body, headers) do
    %{"Content-Length" => content_length_str} = headers
    content_length = String.to_integer(content_length_str)
    body_length = byte_size(body)
    case (body_length - content_length) do
      length when length < 0 ->
        raise %SerializeError{pos: body_length}
      length when length > 0 ->
        raise %SerializeError{pos: content_length, value: body}
      _ ->
        Poison.decode!(body)
    end
  end
end
