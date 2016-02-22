defmodule GameManager.Player.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def start_child(player_id, table_id) do
    Supervisor.start_child(__MODULE__, [player_id, table_id])
  end

  def init(:ok) do
    children = [worker(GameManager.Player.Player, [])]

    supervise(children, strategy: :simple_one_for_one)
  end
end
