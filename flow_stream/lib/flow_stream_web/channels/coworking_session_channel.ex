defmodule FlowStreamWeb.CoworkingSessionChannel do
  use FlowStreamWeb, :channel

  @impl true
  def join("coworking_session:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (coworking_session:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  @impl true
  def handle_in("create_session", %{"name" => name} = _payload, socket) do
    uuid = UUID.uuid4()

    case Firestore.create_session(%{id: uuid, name: name}) do
      {:ok, new_session} ->
        {:reply, {:ok, new_session}, socket}

      {:error, error} ->
        error_message = "Failed to create session: #{inspect(error)}"
        {:reply, {:error, error_message}, socket}
    end
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
