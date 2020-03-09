# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :ex_mmog, ExMmogWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "mdAJxKEaGwUEd9xeiSuoPgDRYjhGR+RV2s4j57XL8dvQqXi3e5SjpK2DfJdKcw0c",
  render_errors: [view: ExMmogWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ExMmog.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "G2zBvZB0/PuENilAgrzTxA3Lqq97/0ur"
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
