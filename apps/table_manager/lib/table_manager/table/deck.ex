defmodule TableManager.Table.Deck do
  defmodule Card do
    defstruct suit: nil, rank: nil
  end

  defmodule Deck do
    @suit ~w[H C D S]
    @rank ~w[A 2 3 4 5 6 7 8 9 10 J Q K]

    def new do
      for r <- @rank, s <- @suit, do: %Card{suit: s, rank: r}
    end
  end

  # Client Api
  def shuffle(table_id) do
    GenServer.cast(table_name(table_id), :shuffle)
  end

  def show_deck(table_id) do
    GenServer.call(table_name(table_id), :show_deck)
  end

  def hit(table_id) do
    GenServer.call(table_name(table_id), :hit)
  end

  # GenServer Api
  def start_link(table_id) do
    GenServer.start_link(__MODULE__, :ok, [name: table_name(table_id)])
  end

  def init(:ok) do
    :timer.send_after(1_000, :shuffle)
    {:ok, Deck.new}
  end

  def handle_info(:shuffle, deck), do: {:noreply, Enum.shuffle(deck)}

  def handle_cast(:shuffle, deck), do: {:noreply, Enum.shuffle(deck)}

  def handle_call(:show_deck, _from, deck) do
    deck_output = Enum.map(deck, fn(card) -> "#{card.suit} - #{card.rank}" end)
    {:reply, deck_output, deck}
  end

  def handle_call(:hit, _from, deck) do
    {:reply, List.first(deck), List.delete_at(deck, 0)}
  end

  defp table_name(table_id), do: :"table_#{table_id}"
end
