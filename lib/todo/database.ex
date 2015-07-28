defmodule Todo.Database do
  use GenServer
  require Logger

  def start_link(db_folder) do
    Logger.debug "Starting Database on #{db_folder}"
    GenServer.start_link(__MODULE__, db_folder, name: :database_server)
  end

  def store(key, data) do
    key
    |> choose_worker
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    key
    |> choose_worker
    |> Todo.DatabaseWorker.get(key)
  end

  defp choose_worker(key) do
    GenServer.call(:database_server, {:get_worker, key})
  end


  def init(db_folder) do
    File.mkdir_p(db_folder)
    {:ok, start_workers(db_folder, 3)}
  end

  defp start_workers(db_folder, n) do
    for index <- 1..n, into: HashDict.new do
      {:ok, pid} = Todo.DatabaseWorker.start_link(db_folder)
      {index - 1, pid}
    end
  end

  def handle_call({:get_worker, key}, _, workers) do
    n = :erlang.phash2(key, workers.size)
    {:reply, workers[n], workers}
  end

end
