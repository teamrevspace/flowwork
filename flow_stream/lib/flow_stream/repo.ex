defmodule FlowStream.Repo do
  use Ecto.Repo,
    otp_app: :flow_stream,
    adapter: Ecto.Adapters.Postgres
end
