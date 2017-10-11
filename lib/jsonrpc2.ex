defmodule JSONRPC2 do
  @moduledoc ~S"""
  `JSONRPC2` is an Elixir library for JSON-RPC 2.0.

  It includes request and response utility modules, a transport-agnostic server handler, a
  line-based TCP server and client, which are based on [Ranch](https://github.com/ninenines/ranch)
  and [shackle](https://github.com/lpgauth/shackle), respectively, and a JSON-in-the-body HTTP(S)
  server and client, based on [Plug](https://github.com/elixir-lang/plug) and
  [hackney](https://github.com/benoitc/hackney), respectively.

  ## TCP Example

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
          IO.puts "You have been notified, #{name}!"
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
      IO.inspect Client.hello("Elixir")
      #=> {:ok, "Hello, Elixir!"}

      # Make a call with the client to the server, using named args
      IO.inspect Client.hello2(name: "Elixir")
      #=> {:ok, "Hello again, Elixir!"}

      # Make a call with the client to the server asynchronously
      {:ok, request_id} = Client.subtract(2, 1)
      IO.puts "non-blocking!"
      #=> non-blocking!
      IO.inspect JSONRPC2.Clients.TCP.receive_response(request_id)
      #=> {:ok, 1}

      # Notifications
      Client.notify("Elixir")
      #=> You have been notified, Elixir!

  ## HTTP Example

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
          IO.puts "You have been notified, #{name}!"
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
      IO.inspect Client.hello("Elixir")
      #=> {:ok, "Hello, Elixir!"}

      # Make a call with the client to the server, using named args
      IO.inspect Client.hello2(name: "Elixir")
      #=> {:ok, "Hello again, Elixir!"}

      # Notifications
      Client.notify("Elixir")
      #=> You have been notified, Elixir!

  ## Serializers

  Any module which conforms to the same API as Poison's `Poison.encode/1` and `Poison.decode/1` can
  be provided as a serializer to the functions which accept them.
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

  @typedoc "A JSON-RPC 2.0 request ID."
  @type id :: String.t | number
end
