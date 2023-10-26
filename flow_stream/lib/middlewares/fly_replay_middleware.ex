defmodule FlowStreamWeb.FlyReplayMiddleware do
  @behaviour Plug

  import Plug.Conn
  require Logger

  def init(opts), do: opts

  def call(conn, _opts) do
    case {conn.params["fly_instance_id"], get_req_header(conn, "fly-replay-src")} do
      {nil, _} ->
        # No instance ID provided, proceed as normal
        conn
        |> analyze_conn()

      {instance_id, []} ->
        # No fly-replay-src header, check the instance ID
        current_instance_id = System.get_env("FLY_ALLOC_ID") |> String.split("-") |> hd()

        if current_instance_id == instance_id do
          # Instance IDs match, proceed as normal
          conn
          |> analyze_conn()
        else
          # Instance IDs do not match, asks the load balancer to retry the request on a different instance
          conn
          |> put_resp_header("fly-replay", "instance=#{instance_id}")
          |> analyze_conn()
        end

      {_instance_id, _replay_src} ->
        # fly-replay-src header is present, this is a replayed request, do not inject fly-replay header
        conn
    end
  end

  defp analyze_conn(conn) do
    Logger.debug("#{inspect(conn.scheme)} #{inspect(conn.method)} #{inspect(conn.path_info)}")
    Logger.debug("req_headers:   #{inspect(conn.req_headers)}")
    Logger.debug("assigns:       #{inspect(conn.assigns)}")
    Logger.debug("resp_headers:  #{inspect(conn.resp_headers)}")
    conn
  end
end
