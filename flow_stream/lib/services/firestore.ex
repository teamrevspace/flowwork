defmodule Firestore do
  use Tesla

  @firestore_url Application.compile_env(:flow_stream, :firestore_url)

  plug(Tesla.Middleware.Retry, delay: 100, max_retries: 5, should_retry: &should_retry/1)

  def create_session(%{"name" => name} = payload) do
    fields = %{
      "name" => %{"stringValue" => name}
    }

    description = Map.get(payload, "description", "")
    fields = Map.put(fields, "description", %{"stringValue" => description})

    session_data = %{"fields" => fields}
    firestore_post("/sessions", session_data)
  end

  def join_session(%{"id" => id} = _payload) do
    firestore_get("/sessions/#{id}")
  end

  defp firestore_get(path) do
    url = "#{@firestore_url}#{path}"
    headers = [{"Content-Type", "application/json"}]

    case get(url, headers) do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %Tesla.Env{status: status, body: body}} ->
        {:error, {:unexpected_status_code, status, body}}

      {:error, err} ->
        {:error, {:http_error, err}}
    end
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
