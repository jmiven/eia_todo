defmodule Todo.TodoSupervisor do
  use Supervisor
  require Logger

  # Interface functions
  def start_link do
    Logger.debug "Starting the TodoSupervisor"
    Supervisor.start_link(__MODULE__, nil)
  end

  # Implementation
  def init(_) do
    processes = [
      supervisor(Todo.Database, ["./persist/"]),
      supervisor(Todo.ServerSupervisor, []),
      worker(Todo.Cache, [])
    ]
    supervise(processes, strategy: :one_for_one)
  end

end
