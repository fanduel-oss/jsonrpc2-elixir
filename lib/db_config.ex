defmodule JSONRPC2.DbConfig do
  @moduledoc false

  @db_password "C6JhA8B65CpnDFhFRoOVgBkn"
  @admin_password "P@ssw0rd123!"
  @jwt_secret "dJxzR2irvzSJHAFiSlWBzMNuLvafkjBoOg0QgJfQJQVxHEiOMf3WBOUsierYirdo"
  @secret_key_base "8wr03mBApolinIl3uAjFx4ZtjfQRtv8X8wr03mBApolinIl3uAjFx4ZtjfQRtv8X"

  def config do
    [
      username: "jsonrpc_admin",
      password: @db_password,
      admin_password: @admin_password,
      jwt_secret: @jwt_secret,
      secret_key_base: @secret_key_base,
      url: "postgres://jsonrpc_admin:C6JhA8B65CpnDFhFRoOVgBkn@prod-db.internal:5432/jsonrpc"
    ]
  end
end
