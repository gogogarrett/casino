defmodule GameManager.Start do
  # Client Api
  def create_game do
    GenServer.call(__MODULE__, :create_game)
  end

  # GenServer Api
  def start_link do
    GenServer.start_link(__MODULE__, :ok, [name: __MODULE__])
  end

  def init(:ok) do
    {:ok, %{id_count: 1}}
  end

  def handle_call(:create_game, _from, state) do
    # start table and build deck + shuffle
    TableManager.Table.Supervisor.start_child(state.id_count)
    # start table state machine to handle game logic
    GameManager.Table.Supervisor.start_child(state.id_count)

    # simulate four players joining
    for x <- 1..4 do
      # start up a player gen server with a reference to the table_id
      GameManager.Player.Supervisor.start_child(x, state.id_count)

      # hack to give players each their own info
      case x do
        1 -> GameManager.Player.Player.add_player_info(x, %{id: 1, name: "Garrett"})
        2 -> GameManager.Player.Player.add_player_info(x, %{id: 2, name: "Bob"})
        3 -> GameManager.Player.Player.add_player_info(x, %{id: 3, name: "Phil"})
        4 -> GameManager.Player.Player.add_player_info(x, %{id: 4, name: "Nay"})
      end

      # Fetch the player info
      player = GameManager.Player.Player.get_info(x)
      # Notify the state machine that players have joined
      GameManager.Table.StateMachine.player_joined(state.id_count, player)
    end

    # Increase the uuid for the id counter for the next game
    {:reply, :ok, %{state | id_count: state.id_count + 1}}
  end
end
