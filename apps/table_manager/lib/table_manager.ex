defmodule TableManager do
  use Application

  def start(_type, _args) do
    TableManager.Table.Supervisor.start_link(:ok)
  end
end
