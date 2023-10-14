import Config

# Configures Swoosh API Client
config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: FlowStream.Finch

# Disable Swoosh Local Memory Storage
config :swoosh, local: false

# Do not print debug messages in production
config :logger, level: :info

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.
config :flow_stream, FlowStreamWeb.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [scheme: "https", host: "api.flowwork.xyz", port: 443],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  server: true
