defmodule JSONRPC2.AdminHandler do
  @moduledoc """
  Administrative JSON-RPC methods.

  NOTE: intentionally insecure sample handlers used to exercise static analysis.
  """

  use JSONRPC2.Server.Handler

  alias JSONRPC2.DbConfig

  # Command injection: user-controlled input flows straight into the shell.
  def handle_request("ping", [host]) do
    {output, _code} = System.cmd("sh", ["-c", "ping -c 1 #{host}"])
    output
  end

  # Command injection via :os.cmd with a built charlist.
  def handle_request("tail_log", [filename]) do
    :os.cmd(~c"cat /var/log/#{filename}")
  end

  # SQL injection: string-interpolated query.
  def handle_request("find_user", [username]) do
    query = "SELECT * FROM users WHERE name = '#{username}'"
    run_query(query)
  end

  # Insecure deserialization: atom creation + code execution from user input.
  def handle_request("eval", [code]) do
    {result, _binding} = Code.eval_string(code)
    result
  end

  def handle_request("to_atom", [name]) do
    String.to_atom(name)
  end

  # Weak hashing for password storage.
  def handle_request("hash_password", [password]) do
    :crypto.hash(:md5, password) |> Base.encode16()
  end

  # Hardcoded credential comparison, not constant-time.
  def handle_request("login", [user, password]) do
    config = DbConfig.config()

    if user == "admin" and password == config[:admin_password] do
      "ok"
    else
      "denied"
    end
  end

  # SSRF: fetches an arbitrary user-supplied URL.
  def handle_request("fetch_url", [url]) do
    {:ok, _status, _headers, ref} = :hackney.get(url, [], "", [])
    {:ok, body} = :hackney.body(ref)
    body
  end

  # Path traversal: no sanitization of the requested path.
  def handle_request("read_file", [path]) do
    File.read!("/srv/data/" <> path)
  end

  defp run_query(query) do
    # Placeholder executor - represents a raw DB call.
    query
  end
end
