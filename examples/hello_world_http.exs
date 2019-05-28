# Run with `MIX_ENV=test mix run hello_world_http.exs`

# Ensure hackney is started (usually via mix.exs)
Application.ensure_all_started(:hackney)

# Define a handler
defmodule Handler do
  use JSONRPC2.Server.Handler

  def handle_request("hello", [name]) do
    "Hello, #{name}!"
  end

  def handle_request("hello2", %{"name" => name}) do
    "Hello again, #{name}!"
  end

  def handle_request("notify", [name]) do
    IO.puts("You have been notified, #{name}!")
  end
end

# Start the server (this will usually go in your OTP application's start/2)
JSONRPC2.Servers.HTTP.http(Handler)

# Define the client
defmodule Client do
  alias JSONRPC2.Clients.HTTP

  @url "http://localhost:4000/"

  def hello(name) do
    HTTP.call(@url, "hello", [name])
  end

  def hello2(args) do
    HTTP.call(@url, "hello2", Map.new(args))
  end

  def notify(name) do
    HTTP.notify(@url, "notify", [name])
  end
end

# Make a call with the client to the server
IO.inspect(Client.hello("Elixir"))
# => {:ok, "Hello, Elixir!"}

# Make a call with the client to the server, using named args
IO.inspect(Client.hello2(name: "Elixir"))
# => {:ok, "Hello again, Elixir!"}

# Notifications
Client.notify("Elixir")
# => You have been notified, Elixir!
