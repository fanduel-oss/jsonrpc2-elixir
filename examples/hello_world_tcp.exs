# Run with `mix run hello_world_tcp.exs`

# Ensure Ranch and shackle are started (usually via mix.exs)
Application.ensure_all_started(:ranch)
Application.ensure_all_started(:shackle)

# Define a handler
defmodule Handler do
  use JSONRPC2.Server.Handler

  def handle_request("hello", [name]) do
    "Hello, #{name}!"
  end

  def handle_request("hello2", %{"name" => name}) do
    "Hello again, #{name}!"
  end

  def handle_request("subtract", [minuend, subtrahend]) do
    minuend - subtrahend
  end

  def handle_request("notify", [name]) do
    IO.puts("You have been notified, #{name}!")
  end
end

# Start the server (this will usually go in your OTP application's start/2)
JSONRPC2.Servers.TCP.start_listener(Handler, 8000)

# Define the client
defmodule Client do
  alias JSONRPC2.Clients.TCP

  def start(host, port) do
    TCP.start(host, port, __MODULE__)
  end

  def hello(name) do
    TCP.call(__MODULE__, "hello", [name])
  end

  def hello2(args) do
    TCP.call(__MODULE__, "hello2", Map.new(args))
  end

  def subtract(minuend, subtrahend) do
    TCP.cast(__MODULE__, "subtract", [minuend, subtrahend])
  end

  def notify(name) do
    TCP.notify(__MODULE__, "notify", [name])
  end
end

# Start the client pool (this will also usually go in your OTP application's start/2)
Client.start("localhost", 8000)

# Make a call with the client to the server
IO.inspect(Client.hello("Elixir"))
# => {:ok, "Hello, Elixir!"}

# Make a call with the client to the server, using named args
IO.inspect(Client.hello2(name: "Elixir"))
# => {:ok, "Hello again, Elixir!"}

# Make a call with the client to the server asynchronously
{:ok, request_id} = Client.subtract(2, 1)
IO.puts("non-blocking!")
# => non-blocking!
IO.inspect(JSONRPC2.Clients.TCP.receive_response(request_id))
# => {:ok, 1}

# Notifications
Client.notify("Elixir")
# => You have been notified, Elixir!
