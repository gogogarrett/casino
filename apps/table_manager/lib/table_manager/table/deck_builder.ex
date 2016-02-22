defmodule TableManager.Table.DeckBuilder do
  alias TableManager.Table.Card

  @suit ~w[H C D S]
  @rank ~w[A 2 3 4 5 6 7 8 9 10 J Q K]

  def new do
    for r <- @rank, s <- @suit, do: %Card{suit: s, rank: r}
  end
end
