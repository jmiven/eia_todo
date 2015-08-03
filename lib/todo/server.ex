defmodule Todo.Server do
  use GenServer
  require Logger

  # interface
  def start_link(todo_list_name) do
    Logger.debug "Starting a todo server for #{todo_list_name}"
    GenServer.start_link(__MODULE__, todo_list_name, name: via_tuple(todo_list_name))
  end

  def add_entry(todo_server, new_entry) do
    GenServer.cast(todo_server, {:add_entry, new_entry})
  end

  def update_entry(todo_server, entry_id, updating_lambda) do
    GenServer.cast(todo_server, {:update_entry, entry_id, updating_lambda})
  end

  def delete_entry(todo_server, entry_id) do
    GenServer.cast(todo_server, {:delete_entry, entry_id})
  end

  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end

  def whereis(name) do
    Todo.ProcessRegistry.whereis_name({:todo_server, name})
  end

  defp via_tuple(name) do
    {:via, Todo.ProcessRegistry, {:todo_server, name}}
  end

  # gen_server implementation
  def init(name) do
    :timer.send_interval(5_000, :todo_cleanup)
    {:ok, {name, Todo.Database.get(name) || Todo.List.new}}
  end

  def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
    new_state = Todo.List.add_entry(todo_list, new_entry)
    Todo.Database.store(name, new_state)
    {:noreply, {name, new_state}}
  end

  def handle_cast({:update_entry, id, lambda}, {name, todo_list}) do
    new_state = Todo.List.update_entry(todo_list, id, lambda)
    Todo.Database.store(name, new_state)
    {:noreply, {name, new_state}}
  end

  def handle_cast({:delete_entry, id}, {name, todo_list}) do
    new_state = Todo.List.delete_entry(todo_list, id)
    {:noreply, {name, new_state}}
  end

  def handle_call({:entries, date}, _, {_, todo_list} = state) do
    {
        :reply,
        Todo.List.entries(todo_list, date),
        state
    }
  end

  #def handle_info(:todo_cleanup, state) do
  #  IO.inspect state
  #  {:noreply, state}
  #end
  def handle_info(_, state), do: {:noreply, state}

end

