defmodule FlowStreamWeb.CoworkingSessionChannel do
  use FlowStreamWeb, :channel
  alias FlowStream.ChannelMonitor

  @impl true
  def join("coworking_session:lobby", payload, socket) do
    if authorized?(payload) do
      current_user = socket.assigns.current_user

      users =
        ChannelMonitor.user_joined("coworking_session:lobby", current_user)

      Process.send(self(), {:after_join, users}, [])
      {:ok, socket}
    else
      {:error, :unauthorized}
    end
  end

  @impl true
  def terminate(_reason, socket) do
    user_id = socket.assigns.current_user

    users =
      ChannelMonitor.user_left("coworking_session:lobby", user_id)

    lobby_update(socket, users)
    :ok
  end

  @impl true
  def handle_info({:after_join, users}, socket) do
    lobby_update(socket, users)
    {:noreply, socket}
  end

  defp lobby_update(socket, users) do
    broadcast!(socket, "lobby_update", %{users: get_userids(users)})
  end

  defp get_userids(nil), do: []

  defp get_userids(users) do
    Enum.map(users, & &1)
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
  def handle_in("create_session", payload, socket) do
    case Firestore.create_session(payload) do
      {:ok, session} ->
        {:reply, {:ok, session}, socket}

      {:error, error} ->
        error_message = "Failed to create session: #{inspect(error)}"
        {:reply, {:error, error_message}, socket}
    end
  end

  @impl true
  def handle_in("join_session", payload, socket) do
    case Firestore.join_session(payload) do
      {:ok, session} ->
        {:reply, {:ok, session}, socket}

      {:error, error} ->
        error_message = "Failed to join session: #{inspect(error)}"
        {:reply, {:error, error_message}, socket}
    end
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
