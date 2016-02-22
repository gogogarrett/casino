defmodule GameManager.Table.StateMachine do
  def start_link(table_id) do
    :gen_fsm.start_link({:local, table_id(table_id)}, __MODULE__, [], [])
  end

  def get_state(table_id) do
    :gen_fsm.sync_send_event(table_id(table_id), :get_state)
  end

  def player_joined(table_id, player) do
    :gen_fsm.send_event(table_id(table_id), {:player_joined, player})
  end

  def player_left(table_id, player) do
    :gen_fsm.send_event(table_id(table_id), {:player_left, player})
  end

  def get_players(table_id) do
    :gen_fsm.sync_send_event(table_id(table_id), :get_players)
  end

  def init(state) do
    {:ok, :waiting, state}
  end

  @doc """
    State: - waiting
    :get_state event
    :SYNC event

    This will return the current gen_state and the current players
  """
  def waiting(:get_state, from, players) do
    {:reply, {:waiting, players}, :waiting, players}
  end

  @doc """
    State: - waiting
    :get_players event
    :SYNC event

    This will return the current players
  """
  def waiting(:get_players, from, players) do
    {:reply, players, :waiting, players}
  end

  @doc """
    State: - waiting
    :player_joined event
    :ASYNC event

    This will add a player to the list of players. When 4 uniq players
    are present we transition to the `playing` state.

    If there is less than 4 players, we stay in the `waiting` state.
  """
  def waiting({:player_joined, player}, players) do
    new_players = Enum.uniq([player | players])
    if Enum.count(new_players) == 4 do
      # LostLegends.Endpoint.broadcast! "battle:1", "state_changed", %{state: :playing}
      {:next_state, :playing, new_players}
    else
      {:next_state, :waiting, new_players}
    end
  end

  @doc """
    State: - waiting
    :player_left event
    :ASYNC event

    This will remove a player from the state. We stay in the `waiting` state.
  """
  def waiting({:player_left, player}, players) do
    new_players = Enum.reject(players, &(&1.id == player.id))
    {:next_state, :waiting, new_players}
  end

  @doc """
    State: - playing
    :get_state event
    :SYNC event

    This will return the current gen_state and the current players
  """
  def playing(:get_state, from, players) do
    {:reply, {:playing, players}, :playing, players}
  end

  @doc """
    State: - playing
    :get_players event
    :SYNC event

    This will return the current players in the state
  """
  def playing(:get_players, from, players) do
    {:reply, players, :playing, players}
  end

  @doc """
    State: - playing
    :player_left event
    :ASYNC event

    This will remove a player from the state. We stay in the `playing` state.
  """
  def playing({:player_left, player}, players) do
    new_players = Enum.drop(players, player)
    {:next_state, :playing, players}
  end

  defp table_id(table_id), do: :"table:#{table_id}"
end
