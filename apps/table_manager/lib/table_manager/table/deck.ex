defmodule TableManager.Table.Deck do
  defmodule Card do
    defstruct suit: nil, rank: nil

    def value(%TableManager.Table.Deck.Card{suit: _suit, rank: rank} = card)
        when rank in ["2", "3", "4", "5", "6", "7", "8", "9", "10"] do
      String.to_integer(rank)
    end
    def value(%TableManager.Table.Deck.Card{suit: _suit, rank: rank} = card)
        when rank in ["J", "Q", "K"] do
      10
    end
    def value(%TableManager.Table.Deck.Card{suit: _suit, rank: rank} = card)
        when rank == "A" do
      [1, 11]
    end
  end

  defmodule DeckBuilder do
    @suit ~w[H C D S]
    @rank ~w[A 2 3 4 5 6 7 8 9 10 J Q K]

    def new do
      for r <- @rank, s <- @suit, do: %Card{suit: s, rank: r}
    end
  end

  defmodule Hand do
    defstruct cards: []

    def count(%Hand{cards: cards} = hand, take_low \\ true) do
      Enum.reduce(cards, 0, fn(card, acc) ->
        case TableManager.Table.Deck.Card.value(card) do
          [low, high] -> count_ace(acc, low, high, take_low)
          number      -> acc + number
          _           -> acc
        end
      end)
    end

    defp count_ace(acc, low, high, take_low) do
      if take_low do
        acc + low
      else
        acc + high
      end
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
    {:ok, DeckBuilder.new}
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
