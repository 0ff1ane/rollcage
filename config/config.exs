# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :api_server,
  ecto_repos: [ApiServer.Repo, ApiServer.ChRepo],
  generators: [timestamp_type: :utc_datetime, binary_id: true]

# Configure the endpoint
config :api_server, ApiServerWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: ApiServerWeb.ErrorHTML, json: ApiServerWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: ApiServer.PubSub,
  live_view: [signing_salt: "IR6ShoAG"]

config :inertia,
  endpoint: ApiServerWeb.Endpoint,
  static_paths: ["/assets/main.tsx"],
  default_version: "1",
  camelize_props: false,
  history: [encrypt: false],
  ssr: false,
  raise_on_ssr_failure: config_env() != :prod

# Configure the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :api_server, ApiServer.Mailer, adapter: Swoosh.Adapters.Local

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
