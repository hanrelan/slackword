defmodule Slackword.ActiveCrosswordTest do
  use ExUnit.Case, async: false

  alias Slackword.ActiveCrossword
  alias Slackword.ActiveCrossword.Answer

  setup do
    crossword = TestHelper.test_crossword
    {:ok, crossword: crossword, active_crossword: ActiveCrossword.new(crossword)}
  end

  test "answers dimensions is correct", %{active_crossword: %ActiveCrossword{answers: answers}} do
    assert answers.dimensions == {3, 3} 
  end

  test "answers can be added and retrieved", %{active_crossword: active_crossword} do
    answer = %Answer{letter: "A", x: 1, y: 2}
    active_crossword = ActiveCrossword.add_answer(active_crossword, answer) 
    assert answer == ActiveCrossword.get_answer(active_crossword, 1, 2)
  end

  test "rendering with answers", %{active_crossword: active_crossword} do
    active_crossword = ActiveCrossword.add_answer(active_crossword, %Answer{letter: "A", x: 1, y: 2})
    active_crossword = ActiveCrossword.add_answer(active_crossword, %Answer{letter: "O", x: 3, y: 3})
    png = ActiveCrossword.render_png(active_crossword)
    :egd.save(png, "test2.png")
    assert png == TestHelper.test_crossword_answers_png
  end

end
