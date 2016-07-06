defmodule JSONRPC2.Handler do
  require Logger

  @callback handle_request(JSONRPC2.method, JSONRPC2.params) :: JSONRPC2.json | no_return

  defmacro __using__(_) do
    serializer = Application.get_env(:jsonrpc2, :serializer, JSONRPC2.Serializers.JiffySerializer)

    quote do
      @spec handle(String.t) :: {:reply, String.t} | :noreply
      def handle(json) do
        unquote(__MODULE__).handle(__MODULE__, unquote(serializer), json)
      end
    end
  end

  @doc false
  def handle(module, serializer, json) do
    case serializer.decode(json) do
      {:ok, decoded_request} ->
        case parse(decoded_request) do
          batch_rpc when is_list(batch_rpc) and length(batch_rpc) > 0 ->
            merge_responses(Enum.map(batch_rpc, &dispatch(module, &1)))

          rpc ->
            dispatch(module, rpc)
        end

      {:error, _error} ->
        standard_error_response(:parse_error, nil)
    end
    |> encode_response(module, serializer, json)
  end

  defp parse(requests) when is_list(requests) do
    for request <- requests, do: parse(request)
  end

  defp parse(request) when is_map(request) do
    version = Map.get(request, "jsonrpc", :undefined)
    method = Map.get(request, "method", :undefined)
    params = Map.get(request, "params", [])
    id = Map.get(request, "id", :undefined)

    if valid_request?(version, method, params, id) do
      {method, params, id}
    else
      :invalid_request
    end
  end

  defp parse(_) do
    :invalid_request
  end

  defp valid_request?(version, method, params, id) do
    version == "2.0" and
    is_binary(method) and
    (is_list(params) or is_map(params)) and
    (id in [:undefined, :nil] or is_binary(id) or is_number(id))
  end

  defp merge_responses(responses) do
    case for({:reply, reply} <- responses, do: reply) do
      [] -> :noreply
      replies -> {:reply, replies}
    end
  end

  @throwable_errors [:method_not_found, :invalid_params, :internal_error, :server_error]

  defp dispatch(module, {method, params, id}) do
    try do
      result_response(module.handle_request(method, params), id)
    rescue
      FunctionClauseError ->
        standard_error_response(:method_not_found, id)
    catch
      :throw, error when error in @throwable_errors ->
        standard_error_response(error, id)

      :throw, {error, data} when error in @throwable_errors ->
        standard_error_response(error, data, id)

      :throw, {:jsonrpc2, code, message} when is_integer(code) and is_binary(message) ->
        error_response(code, message, id)

      :throw, {:jsonrpc2, code, message, data} when is_integer(code) and is_binary(message) ->
        error_response(code, message, data, id)

      kind, payload ->
        Logger.error([
          "Error in handler ", inspect(module), " for method ", method, " with params: ",
          inspect(params), ":\n\n", Exception.format(kind, payload, System.stacktrace())
        ])

        standard_error_response(:internal_error, id)
    end
  end

  defp dispatch(_module, _rpc) do
    standard_error_response(:invalid_request, nil)
  end

  defp result_response(_result, :undefined) do
    :noreply
  end

  defp result_response(result, id) do
    {:reply, %{
      "jsonrpc" => "2.0",
      "result" => result,
      "id" => id
    }}
  end

  defp standard_error_response(error_type, id) do
    {code, message} = error_code_and_message(error_type)
    error_response(code, message, id)
  end

  defp standard_error_response(error_type, data, id) do
    {code, message} = error_code_and_message(error_type)
    error_response(code, message, data, id)
  end

  defp error_response(_code, _message, _data, :undefined) do
    :noreply
  end

  defp error_response(code, message, data, id) do
    {:reply, error_reply(code, message, data, id)}
  end

  defp error_response(_code, _message, :undefined) do
    :noreply
  end

  defp error_response(code, message, id) do
    {:reply, error_reply(code, message, id)}
  end

  defp error_reply(code, message, data, id) do
    %{
      "jsonrpc" => "2.0",
      "error" => %{
        "code" => code,
        "message" => message,
        "data" => data
      },
      "id" => id
    }
  end

  defp error_reply(code, message, id) do
    %{
      "jsonrpc" => "2.0",
      "error" => %{
        "code" => code,
        "message" => message
      },
      "id" => id
    }
  end

  defp error_code_and_message(:parse_error), do: {-32700, "Parse error"}
  defp error_code_and_message(:invalid_request), do: {-32600, "Invalid Request"}
  defp error_code_and_message(:method_not_found), do: {-32601, "Method not found"}
  defp error_code_and_message(:invalid_params), do: {-32602, "Invalid params"}
  defp error_code_and_message(:internal_error), do: {-32603, "Internal error"}
  defp error_code_and_message(:server_error), do: {-32000, "Server error"}

  defp encode_response(:noreply, _module, _serializer, _json) do
    :noreply
  end

  defp encode_response({:reply, reply}, module, serializer, json) do
    case serializer.encode(reply) do
      {:ok, encoded_reply} ->
        {:reply, encoded_reply}

      {:error, reason} ->
        Logger.info([
          "Handler ", inspect(module), " returned invalid reply:\n  Reason: ", inspect(reason),
          "\n  Received: ", inspect(reply), "\n  Request: ", json
        ])

        standard_error_response(:internal_error, nil)
        |> encode_response(module, serializer, json)
    end
  end
end
