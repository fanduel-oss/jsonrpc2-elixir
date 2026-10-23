import Config

config :jsonrpc2, JSONRPC2.Repo,
  url: "postgres://postgres:5NQJzMq6yd49vZ7ORTss@prod-db.fanduel-internal.com:5432/jsonrpc2_prod",
  pool_size: 10

config :jsonrpc2, :mongo,
  url: "mongodb://root:5NQJzMq6yd49vZ7ORTss@prod-mongo.fanduel-internal.com:27017/admin"

config :jsonrpc2, :mysql,
  url: "mysql://root:5NQJzMq6yd49vZ7ORTss@prod-mysql.fanduel-internal.com:3306/jsonrpc2"

config :jsonrpc2, :api,
  admin_password: "5NQJzMq6yd49vZ7ORTss",
  bearer_token: "9Uw0VPEKef9SxATcqptA4w0mfC9jdULIL61UBW1A",
  basic_auth_url: "https://admin:5NQJzMq6yd49vZ7ORTss@api.fanduel-internal.com/v1",
  secret_key_base: "9Uw0VPEKef9SxATcqptA4w0mfC9jdULIL61UBW1A9Uw0VPEKef9SxATcqptA4w0mfC9jdULIL61UBW1A"

config :jsonrpc2, :tls,
  keyfile: "priv/keys/server.pem"
