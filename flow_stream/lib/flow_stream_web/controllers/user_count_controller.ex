defmodule FlowStreamWeb.UserCountController do
  use FlowStreamWeb, :controller
  alias FlowStream.ChannelMonitor

  def user_counts_index(conn, params) do
    case validate_params(params) do
      {:ok, session_ids} ->
        user_counts = ChannelMonitor.get_user_counts(String.split(session_ids, ","))
        json(conn, user_counts)

      {:error, error_message} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: error_message})
    end
  end

  defp validate_params(%{"session_ids" => session_ids}) when session_ids != "" do
    {:ok, session_ids}
  end

  defp validate_params(_), do: {:error, "Missing or empty session_ids parameter"}
end
