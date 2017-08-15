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
    table
    |> :dets.lookup(key)
    |> format_get_result()
  end

  defp format_get_result([]), do: {:error, :notfound}
  defp format_get_result([{_key, cached_result, _counter}]), do: {:ok, cached_result}
  defp format_get_result(_), do: {:error, :data_error}

  def put(table, key, val) do
    :dets.insert(table, {key, val, 1})
  end

  def incr(table, key) do
    :dets.update_counter(table, key, {3, 1})
  end

  def close do
    GenServer.cast(__MODULE__, :close)
  end

  # GenServer Callbacks

  def init(config) do
    # Start DETS for each table
    refs =
      Enum.map(config[:tables], fn table ->
        filename = Atom.to_string(table) <> ".dets"
        file_path =
          [config[:data_dir], filename]
          |> Path.join()
          |> String.to_char_list()

        {:ok, ref} = :dets.open_file(table, access: :read_write, file: file_path)

        ref
      end)

    {:ok, refs}
  end

  def handle_cast(:close, refs) do
    Enum.each(refs, fn ref ->
      :dets.close(ref)
    end)
    {:noreply, refs}
  end
  def handle_cast(_msg, state), do: {:noreply, state}

  def terminate(_reason, refs) do
    Enum.each(refs, fn ref ->
      :dets.close(ref)
    end)

    :ok
  end

end
