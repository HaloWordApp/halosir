defmodule HaloSir.DetsStore do
  @moduledoc """
  Use `:dets` to cache results.

  Each `cached_result` for a `word` is stored as a tuple:

      {word, cached_result, counter}

  """

  use GenServer

  # Client APIs

  def start_link do
    GenServer.start_link(__MODULE__, Application.get_env(:halosir, __MODULE__), name: __MODULE__)
  end

  def get(table, key) do
    GenServer.call(__MODULE__, {:get, table, key})
  end

  def put(table, key, val) do
    GenServer.cast(__MODULE__, {:put, table, key, val})
  end

  def incr(table, key) do
    GenServer.cast(__MODULE__, {:incr, table, key})
  end

  # GenServer Callbacks

  def init(config) do
    # Start DETS for each table
    refs =
      Enum.map(config[:tables], fn table ->
        filename = Atom.to_string(table) <> ".dets"
        file_path = Path.join([config[:data_dir], filename])

        {:ok, ref} = :dets.open_file(table, file: file_path)

        ref
      end)

    {:ok, refs}
  end

  def handle_call({:get, table, key}, _from, state) do
    result =
      :dets.lookup(table, key)
      |> format_get_result()

    {:reply, result, state}
  end
  def handle_call(_msg, _from, state), do: {:reply, :badmsg, state}

  def handle_case({:put, table, key, val}, state) do
    :dets.insert(table, {key, val, 1})
    {:noreply, state}
  end
  def handle_cast({:incr, table, key}, state) do
    :dets.update_counter(table, key, {3, 1})
    {:noreply, state}
  end
  def handle_cast(_msg, state), do: {:noreply, state}

  defp format_get_result([]), do: {:error, :notfound}
  defp format_get_result([{_key, cached_result, _counter}]), do: {:ok, cached_result}
  defp format_get_result(_), do: {:error, :data_error}

end
