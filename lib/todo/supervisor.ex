defmodule Todo.Supervisor do
  use Supervisor

  # Interface functions
  def start_link do
    Supervisor.start_link(__MODULE__, nil)
  end

  # Implementation
  def init(_) do
    processes = [
      worker(Todo.ProcessRegistry, []),
      supervisor(Todo.Database, ["./persist/"]),
      supervisor(Todo.ServerSupervisor, []),
      worker(Todo.Cache, [])
    ]
    supervise(processes, strategy: :one_for_one)
  end

end
