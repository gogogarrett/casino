defmodule TableManager.Table.Card do
  defstruct suit: nil, rank: nil

  alias TableManager.Table.Card

  def value(%Card{suit: _suit, rank: rank} = card)
      when rank in ["2", "3", "4", "5", "6", "7", "8", "9", "10"] do
    String.to_integer(rank)
  end
  def value(%Card{suit: _suit, rank: rank} = card) when rank in ["J", "Q", "K"] do
    10
  end
  def value(%Card{suit: _suit, rank: rank} = card) when rank == "A" do
    [1, 11]
  end
end
