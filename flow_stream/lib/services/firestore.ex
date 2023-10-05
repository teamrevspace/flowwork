defmodule Firestore do
  use Tesla

  @firestore_url Application.compile_env(:flow_work, :firestore_url)

  plug(Firestore.TokenVerificationMiddleware)
  plug(Tesla.Middleware.Retry, delay: 100, max_retries: 5, should_retry: &should_retry/1)

  def create_session(session_data) do
    firestore_post("/sessions", session_data)
  end

  defp firestore_post(path, data) do
    url = "#{@firestore_url}#{path}"
    headers = [{"Content-Type", "application/json"}]
    body = Jason.encode!(data)

    case post(url, body, headers) do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %Tesla.Env{status: status, body: body}} ->
        {:error, {:unexpected_status_code, status, body}}

      {:error, err} ->
        {:error, {:http_error, err}}
    end
  end

  defp should_retry(%Tesla.Env{status: status}) when status in 500..599, do: true
  defp should_retry(_), do: false
end
