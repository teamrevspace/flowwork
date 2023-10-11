defmodule FlowStream.ChannelMonitor do
  use GenServer

  def init(_) do
    {:ok, %{}}
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def user_joined(channel, user) do
    GenServer.call(__MODULE__, {:user_joined, channel, user})
  end

  def users_in_channel(channel) do
    GenServer.call(__MODULE__, {:users_in_channel, channel})
  end

  def user_left(channel, user_id) do
    GenServer.call(__MODULE__, {:user_left, channel, user_id})
  end

  # GenServer implementation
  def handle_call({:user_joined, channel, user}, _from, state) do
    users = Map.get(state, channel, [])
    new_users = [user | users] |> Enum.uniq()
    new_state = Map.put(state, channel, new_users)
    {:reply, new_users, new_state}
  end

  def handle_call({:users_in_channel, channel}, _from, state) do
    users = Map.get(state, channel, [])
    {:reply, users, state}
  end

  def handle_call({:user_left, channel, user_id}, _from, state) do
    users = Map.get(state, channel, [])
    new_users = Enum.reject(users, &(&1 == user_id))
    new_state = Map.put(state, channel, new_users)
    {:reply, new_users, new_state}
  end
end
