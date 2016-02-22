defmodule TableManager.Table.Hand do
  defstruct cards: []

  alias TableManager.Table.{Card, Hand}

  def count(%Hand{cards: cards}, take_low \\ true) do
    Enum.reduce(cards, 0, fn(card, acc) ->
      case Card.value(card) do
        [low, high] -> count_ace(acc, low, high, take_low)
        number      -> acc + number
      end
    end)
  end

  defp count_ace(acc, low, high, true),  do: acc + low
  defp count_ace(acc, low, high, false), do: acc + high
end
