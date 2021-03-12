# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

# Configure Mix tasks and generators
config :example,
  ecto_repos: [Example.Repo]

config :example_web,
  ecto_repos: [Example.Repo],
  generators: [context_app: :example]

# Configures the endpoint
config :example_web, ExampleWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "XhNSIUVfq+aHmKc0FJsVLlA99EJvqbDdPqv1JG3++85BQjPwS+o3tmt2zVbbgeNr",
  render_errors: [view: ExampleWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Example.PubSub,
  live_view: [signing_salt: "r10Zhl2u"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
