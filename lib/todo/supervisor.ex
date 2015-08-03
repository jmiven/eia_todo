defmodule Todo.Supervisor do
  use Supervisor
  require Logger

  # Interface functions
  def start_link do
    Logger.debug "Starting the top-level supervisor"
    Supervisor.start_link(__MODULE__, nil)
  end

  # Implementation
  def init(_) do
    processes = [
      worker(Todo.ProcessRegistry, []),
      supervisor(Todo.TodoSupervisor, [])
    ]
    supervise(processes, strategy: :rest_for_one)
  end

end
