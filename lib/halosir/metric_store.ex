defmodule HaloSir.MetricStore do
  @moduledoc false
  use Fluxter

  @spec dict_query(atom, boolean, String.t) :: :ok
  def dict_query(dict, cached, word) do
    write("dict_query", [dict: Atom.to_string(dict), cached: cached], [word: word])
  end

  @spec dets_cache(atom, String.t) :: :ok
  def dets_cache(dict, word) do
    write("dets_cache", [dict: Atom.to_string(dict)], [word: word])
  end

  @spec failed_query(atom, String.t) :: :ok
  def failed_query(dict, word) do
    write("failed_query", [dict: Atom.to_string(dict)], [word: word])
  end
end
