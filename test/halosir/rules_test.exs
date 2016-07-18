defmodule HaloSir.RulesTest do
  use ExUnit.Case

  import HaloSir.Rules

  test "Should cache a short word, or a phrase with no more than 3 words" do
    word = "test"
    assert should_cache_word?(word)

    phrase = "hello world"
    assert should_cache_word?(phrase)

    longer_phrase = "test hello word"
    assert should_cache_word?(longer_phrase)
  end

  test "Should not cache phrase with more than 3 words" do
    phrase = "test test test test"
    refute should_cache_word?(phrase)
  end

  test "Should not cache long sentence" do
    sentence = "「涼宮ハルヒの憂鬱」「らき☆すた」「けいおん！」など数々のヒット作を手掛ける京都アニメーションの最新作が発表されました。京都アニメーションの新作はTVアニメシリーズ『氷菓』。原作は米澤穂信の同名小説（第五回角川学園小説大賞ヤングミステリー＆ホラー部門奨励賞受賞作）。放送時期などの詳細は未定。"
    refute should_cache_word?(sentence)
  end
end
