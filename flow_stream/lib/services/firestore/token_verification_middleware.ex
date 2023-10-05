defmodule Firestore.TokenVerificationMiddleware do
  @cert_url "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"

  def verify!(token) do
    case Tesla.get(@cert_url) do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        {:ok, %{"kid" => kid}} = Joken.peek_header(token)

        {true, %{fields: fields}, _} =
          body
          |> Jason.decode!()
          |> JOSE.JWK.from_firebase()
          |> Map.fetch!(kid)
          |> JOSE.JWT.verify(token)

        fields

      {:ok, %Tesla.Env{status: status}} ->
        raise "Failed to get certificates: HTTP #{status}"

      {:error, err} ->
        raise "Failed to get certificates: #{inspect(err)}"
    end
  end

  defp extract_token(headers) do
    headers
    |> Enum.find_value(fn
      {"Authorization", "Bearer " <> token} -> token
      _ -> nil
    end)
  end

  def call(env, next, _opts) do
    case extract_token(env.headers) do
      nil ->
        {:error, :unauthorized}

      token ->
        try do
          verified_token = verify!(token)

          env = %{env | opts: Map.put(env.opts, :verified_token, verified_token)}

          Tesla.run(env, next)
        rescue
          _ -> {:error, :unauthorized}
        end
    end
  end
end
