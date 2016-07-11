defmodule HaloSir.Rules do
  @moduledoc """
  Here defines some boolean functions to regulate some behaviours of HaloSir.
  """

  @doc """
  Don't cache sentences.
  """
  def should_cache_word?(word) do
    word
    |> String.split()
    |> Kernel.length()
    |> Kernel.<=(3)
  end
end
