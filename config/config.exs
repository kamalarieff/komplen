# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :komplen,
  ecto_repos: [Komplen.Repo]

# Configures the endpoint
config :komplen, KomplenWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "8Zc4epSvsRfIfUAHqx7ESaca7j9bcNorhORyVIhaU/ign0HYC2Pg1tuLhz8J0hBB",
  render_errors: [view: KomplenWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Komplen.PubSub,
  live_view: [signing_salt: "/aGLAWcX"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
