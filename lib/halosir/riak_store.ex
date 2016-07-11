defmodule HaloSir.RiakStore do
  @moduledoc false
  use GenServer

  # Client APIs

  def start_link do
    GenServer.start_link(__MODULE__, Application.get_env(:halosir, __MODULE__), name: __MODULE__)
  end

  def get(bucket, key) do
    GenServer.call(__MODULE__, {:get, bucket, key})
  end

  def put(obj) do
    GenServer.cast(__MODULE__, {:put, obj})
  end

  def incr(bucket, key) do
    GenServer.cast(__MODULE__, {:incr, bucket, key})
  end

  # GenServer Callbacks

  def init(config) do
    {:ok, pid} = :riakc_pb_socket.start_link(config[:host], config[:port])
    {:ok, %{pid: pid}}
  end

  def handle_call({:get, bucket, key}, _from, %{pid: pid} = state) do
    {:reply, :riakc_pb_socket.get(pid, bucket, key), state}
  end
  def handle_call(_msg, _from, state), do: {:reply, :badmsg, state}

  def handle_cast({:put, obj}, %{pid: pid} = state) do
    :riakc_pb_socket.put(pid, obj)
    {:noreply, state}
  end
  def handle_cast({:incr, bucket, key}, %{pid: pid} = state) do
    :riakc_pb_socket.counter_incr(pid, bucket, key, 1)
    {:noreply, state}
  end
  def handle_cast(_msg, state), do: {:noreply, state}
end
