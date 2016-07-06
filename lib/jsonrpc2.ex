defmodule JSONRPC2 do
  @moduledoc """
  `JSONRPC2` is an Elixir library for JSON-RPC 2.0.
  """

  @typedoc "A JSON-RPC 2.0 method."
  @type method :: String.t

  @typedoc "A decoded JSON object."
  @type json ::
    nil |
    true |
    false |
    float |
    integer |
    String.t |
    [json] |
    %{optional(String.t) => json}

  @typedoc "A JSON-RPC 2.0 params value."
  @type params :: [json] | %{optional(String.t) => json}
end
