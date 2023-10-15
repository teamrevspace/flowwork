defmodule FlowStreamWeb.CoworkingSessionChannel do
  use FlowStreamWeb, :channel
  alias FlowStream.ChannelMonitor

  @impl true
  def join("coworking_session:" <> session_id, payload, socket) do
    if authorized?(payload) do
      current_user = socket.assigns.current_user
      socket = assign(socket, :session_id, session_id)

      cond do
        session_id == "lobby" ->
          {:ok, socket}

        true ->
          users = ChannelMonitor.user_joined("coworking_session:#{session_id}", current_user)

          Process.send(self(), {:after_join, users}, [])
          {:ok, socket}
      end
    else
      {:error, :unauthorized}
    end
  end

  @impl true
  def terminate(_reason, socket) do
    user_id = socket.assigns.current_user
    session_id = socket.assigns.session_id

    users =
      ChannelMonitor.user_left("coworking_session:#{session_id}", user_id)

    lobby_update(socket, users)
    :ok
  end

  @impl true
  def handle_info({:after_join, users}, socket) do
    lobby_update(socket, users)
    {:noreply, socket}
  end

  defp lobby_update(socket, users) do
    broadcast!(socket, "lobby_update", %{userIds: get_userids(users)})
  end

  defp get_userids(nil), do: []

  defp get_userids(users) do
    Enum.map(users, & &1)
  end

  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  @impl true
  def handle_in("create_session", payload, socket) do
    case Firestore.create_session(payload) do
      {:ok, session} ->
        session_path = Map.get(session, "name")
        session_id = List.last(String.split(session_path, "/"))
        # Update the session_id in socket assigns
        socket = assign(socket, :session_id, session_id)

        # Join the user to the new session
        join("coworking_session:" <> session_id, %{}, socket)
        {:reply, {:ok, session}, socket}

      {:error, error} ->
        error_message = "Failed to create session: #{inspect(error)}"
        {:reply, {:error, error_message}, socket}
    end
  end

  @impl true
  def handle_in("join_session", _payload, socket) do
    session_id = socket.assigns.session_id

    case Firestore.join_session(session_id) do
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
