defmodule GameManager.Player.Player do
  # Client Api
  def add_player_info(player_id, info) do
    GenServer.cast(player_id(player_id), {:add_info, info})
  end

  def get_info(player_id) do
    GenServer.call(player_id(player_id), :get_info)
  end

  def hit(player_id) do
    GenServer.call(player_id(player_id), :hit)
  end

  def stay(player_id) do
    GenServer.call(player_id(player_id), :stay)
  end

  # GenServer Api
  def start_link(player_id, table_id) do
    GenServer.start_link(__MODULE__, table_id, [name: player_id(player_id)])
  end

  def init(table_id) do
    {:ok, %{table_id: table_id, cards: []}}
  end

  def handle_call(:hit, _from, state) do
    card = TableManager.Table.Deck.hit(state.table_id)

    new_cards = case Map.get(state, :cards) do
      nil -> [card]
      cards -> [card] ++ state.cards
    end

    {:reply, card, %{state | cards: List.flatten(new_cards)}}
  end

  def handle_call(:stay, _from, state) do
    # Not implemented yet
    # this will delegate responsibility to the state machine
    {:reply, GameManager.Table.StateMachine.next_player(state.table_id), state}
  end

  def handle_call(:get_info, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:add_info, info}, state) do
    player_info = Map.put(state, :name, info[:name]) |> Map.put(:id, info[:id])
    {:noreply, player_info}
  end

  defp player_id(player_id), do: :"player_#{player_id}"
end
