defmodule JSONRPC2.Servers.TCP.Protocol do
  @moduledoc false

  use GenServer
  require Logger

  if Code.ensure_loaded?(:ranch_protocol) do
    @behaviour :ranch_protocol
  end

  def start_link(ref, socket, transport, {jsonrpc2_handler, timeout, line_packet}) do
    :proc_lib.start_link(__MODULE__, :init, [
      {ref, socket, transport, jsonrpc2_handler, timeout, line_packet}
    ])
  end

  def init({ref, socket, transport, jsonrpc2_handler, timeout, line_packet}) do
    :ok = :proc_lib.init_ack({:ok, self()})
    :ok = :ranch.accept_ack(ref)
    :ok = transport.setopts(socket, active: :once, packet: if(line_packet, do: :line, else: 4))
    state = {ref, socket, transport, jsonrpc2_handler, timeout, line_packet}
    :gen_server.enter_loop(__MODULE__, [], state, timeout)
  end

  def handle_info({:tcp, socket, data}, state) do
    {_ref, _socket, transport, jsonrpc2_handler, timeout, line_packet} = state
    transport.setopts(socket, active: :once)

    {:ok, _} =
      Task.start(fn ->
        case jsonrpc2_handler.handle(data) do
          {:reply, reply} -> transport.send(socket, terminate_packet(reply, line_packet))
          :noreply -> :noreply
        end
      end)

    {:noreply, state, timeout}
  end

  def handle_info({:tcp_closed, _socket}, state),
    do: {:stop, :normal, state}

  def handle_info({:tcp_error, _, reason}, state),
    do: {:stop, reason, state}

  def handle_info(:timeout, state),
    do: {:stop, :normal, state}

  def handle_info(message, state) do
    _ =
      Logger.info([
        inspect(__MODULE__),
        " with state:\n",
        inspect(state),
        "\nreceived unexpected message:\n",
        inspect(message)
      ])

    {:noreply, state}
  end

  defp terminate_packet(reply, true), do: [reply, "\r\n"]
  defp terminate_packet(reply, false), do: reply
end
