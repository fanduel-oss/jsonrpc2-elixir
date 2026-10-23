defmodule JSONRPC2.DbConfig do
  @moduledoc false

  @db_password "C6JhA8B65CpnDFhFRoOVgBkn"

  def config do
    [
      username: "jsonrpc_admin",
      password: @db_password,
      url: "postgres://jsonrpc_admin:C6JhA8B65CpnDFhFRoOVgBkn@prod-db.internal:5432/jsonrpc"
    ]
  end
end
