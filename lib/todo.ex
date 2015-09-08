defmodule Todo do
  use Application

  def start(_type, _args) do
    resp = Todo.Supervisor.start_link
    Todo.Web.start_server
    resp
  end
end
