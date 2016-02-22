defmodule GameManager.Table.StateMachine do
  def start_link(table_id) do
    :gen_fsm.start_link({:local, table_id(table_id)}, __MODULE__, table_id, [])
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

  def next_player(table_id) do
    :gen_fsm.sync_send_event(table_id(table_id), :next_player)
  end

  def current_player(table_id) do
    :gen_fsm.sync_send_event(table_id(table_id), :current_player)
  end

  def init(table_id) do
    {:ok, :waiting, %{
      players: [],
      finished_players: [],
      table_id: table_id,
      current_player: nil}
    }
  end

  @doc """
    State: - waiting
    :get_state event
    :SYNC event

    This will return the current gen_state and the current players
  """
  def waiting(:get_state, from, %{players: players} = state) do
    {:reply, {:waiting, players}, :waiting, state}
  end

  @doc """
    State: - waiting
    :get_players event
    :SYNC event

    This will return the current players
  """
  def waiting(:get_players, from, %{players: players} = state) do
    {:reply, players, :waiting, state}
  end

  @doc """
    State: - waiting
    :player_joined event
    :ASYNC event

    This will add a player to the list of players. When 4 uniq players
    are present we transition to the `playing` state.

    If there is less than 4 players, we stay in the `waiting` state.
  """
  def waiting({:player_joined, player}, %{players: players, table_id: table_id} = state) do
    new_players = Enum.uniq([player | players])
    if Enum.count(new_players) == 4 do
      current_player = List.first(players)
      {:next_state, :playing, %{state | players: new_players, current_player: current_player}}
    else
      {:next_state, :waiting, %{state | players: new_players}}
    end
  end

  @doc """
    State: - waiting
    :player_left event
    :ASYNC event

    This will remove a player from the state. We stay in the `waiting` state.
  """
  def waiting({:player_left, player}, %{players: players} = state) do
    new_players = Enum.reject(players, &(&1.id == player.id))
    {:next_state, :waiting, %{state | players: new_players}}
  end

  @doc """
    State: - playing
    :get_state event
    :SYNC event

    This will return the current gen_state and the current players
  """
  def playing(:get_state, from, %{players: players} = state) do
    {:reply, {:playing, players}, :playing, state}
  end

  @doc """
    State: - playing
    :get_players event
    :SYNC event

    This will return the current players in the state
  """
  def playing(:get_players, from, %{players: players} = state) do
    {:reply, players, :playing, state}
  end

  @doc """
    State: - playing
    :next_player event
    :SYNC event

    Transitions from the current player to the next player in the table
  """
  def playing(:next_player, from, %{players: players, current_player: current_player} = state) do
    finished_players = [current_player] ++ state.finished_players
    remaning_players = Enum.reject(players, &(&1.id == current_player.id))

    next_state = %{state |
      finished_players: List.flatten(finished_players),
      current_player: List.first(remaning_players),
      players: remaning_players
    }

    {:reply, next_state.current_player, :playing, next_state}
  end

  @doc """
    State: - playing
    :current_player event
    :SYNC event

    Returns the current player who needs to play
  """
  def playing(:current_player, from, %{current_player: current_player} = state) do
    {:reply, current_player, :playing, state}
  end

  @doc """
    State: - playing
    :player_left event
    :ASYNC event

    This will remove a player from the state. We stay in the `playing` state.
  """
  def playing({:player_left, player}, %{players: players} = state) do
    new_players = Enum.drop(players, player)
    {:next_state, :playing, %{state | players: new_players}}
  end

  defp table_id(table_id), do: :"table:#{table_id}"
end
