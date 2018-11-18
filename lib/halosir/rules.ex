defmodule HaloSir.Rules do
  @moduledoc """
  Here defines some boolean functions to regulate some behaviours of HaloSir.
  """

  @doc """
  Don't cache sentences.
  """
  def should_cache_word?(word) do
    not_too_long?(word) && not_sentence?(word) && has_english_letter?(word)
  end

  defp not_sentence?(word) do
    word
    |> String.split()
    |> Kernel.length()
    |> Kernel.<=(3)
  end

  defp not_too_long?(word) do
    String.length(word) <= 20
  end

  @reg ~r/[a-zA-Z]/
  defp has_english_letter?(word) do
    Regex.match?(@reg, word)
  end
end
