defmodule FlowStreamWeb.SessionController do
  use FlowStreamWeb, :controller

  def sessions_index(conn, params) do
    case validate_params(params) do
      {:ok, session_id} ->
        case find_session(session_id) do
          {:ok, session_info} ->
            json(conn, parse_to_json(session_info))

          {:error, _reason} ->
            conn
            |> put_status(:not_found)
            |> json(%{error: "Session not found"})
        end

      {:error, error_message} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: error_message})
    end
  end

  defp validate_params(%{"session_id" => session_id}) when session_id != "" do
    {:ok, session_id}
  end

  defp validate_params(_), do: {:error, "Missing or empty session_id parameter"}

  defp find_session(id) do
    result = Firestore.get_document("/sessions/#{id}")

    case result do
      {:ok, %{"fields" => fields}} -> {:ok, fields}
      {:error, reason} -> {:error, reason}
    end
  end

  defp parse_to_json(map) do
    Map.new(map, fn {key, value} ->
      {key,
       case value do
         %{"stringValue" => str_value} ->
           str_value

         %{"arrayValue" => %{"values" => array_values}} ->
           Enum.map(array_values, fn %{"stringValue" => value} -> value end)

         _ ->
           value
       end}
    end)
  end
end
