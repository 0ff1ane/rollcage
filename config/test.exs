import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :api_server, ApiServer.Repo,
  username: "sid",
  password: "",
  hostname: "localhost",
  database: "rollcage_api_server_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

config :api_server, ApiServer.ChRepo,
  hostname: "localhost",
  database: "rollcage_clickhouse_server_test#{System.get_env("MIX_TEST_PARTITION")}"

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :api_server, ApiServerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "ZbsqGWmeRIx/oC13phgraX+TwHKplx0eaEBOVIl9w1qnhWZhOZTKa2L8j1nd9/gT",
  server: false

# In test we don't send emails
config :api_server, ApiServer.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# Sort query params output of verified routes for robust url comparisons
config :phoenix,
  sort_verified_routes_query_params: true
