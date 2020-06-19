defmodule JSONRPC2.Clients.TCP.Protocol do
  @moduledoc false

  if Code.ensure_loaded?(:shackle_client) do
    @behaviour :shackle_client
  end

  require Logger

  def init do
    serializer = Application.get_env(:jsonrpc2, :serializer)
    {:ok, %{request_counter: 0, serializer: serializer}}
  end

  def setup(_socket, state) do
    {:ok, state}
  end

  def handle_request({:call, method, params, string_id}, state) do
    external_request_id_int = external_request_id(state.request_counter)

    external_request_id =
      if string_id do
        Integer.to_string(external_request_id_int)
      else
        external_request_id_int
      end

    {:ok, data} =
      {method, params, external_request_id}
      |> JSONRPC2.Request.serialized_request(state.serializer)

    new_state = %{state | request_counter: external_request_id_int + 1}
    {:ok, external_request_id, data, new_state}
  end

  def handle_request({:notify, method, params}, state) do
    {:ok, data} = JSONRPC2.Request.serialized_request({method, params}, state.serializer)

    {:ok, nil, data, state}
  end

  def handle_data(data, state) do
    case JSONRPC2.Response.deserialize_response(data, state.serializer) do
      {:ok, {nil, result}} ->
        _ =
          Logger.error([
            inspect(__MODULE__),
            " received response with null ID: ",
            inspect(result)
          ])

        {:ok, [], state}

      {:ok, {id, result}} ->
        {:ok, [{id, result}], state}

      {:error, error} ->
        _ =
          Logger.error([
            inspect(__MODULE__),
            " received invalid response, error: ",
            inspect(error)
          ])

        {:ok, [], state}
    end
  end

  def terminate(_state) do
    :ok
  end

  parent = __MODULE__

  defmodule LineTerminated do
    @moduledoc false

    defdelegate init, to: parent

    defdelegate setup(socket, state), to: parent

    def handle_request(request, state) do
      {:ok, external_request_id, data, state} = unquote(parent).handle_request(request, state)
      {:ok, external_request_id, [data, "\r\n"], state}
    end

    defdelegate handle_data(data, state), to: parent
    defdelegate terminate(state), to: parent
  end

  defp external_request_id(request_counter) do
    rem(request_counter, 2_147_483_647)
  end
end
