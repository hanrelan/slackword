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
    png = ActiveCrossword.render(active_crossword)
    :egd.save(png, "test2.png")
    assert png == TestHelper.test_crossword_answers_png
  end

  test "rendering errors without solutions", %{active_crossword: active_crossword} do
    active_crossword = ActiveCrossword.add_answer(active_crossword, %Answer{letter: "B", x: 1, y: 2})
    active_crossword = ActiveCrossword.add_answer(active_crossword, %Answer{letter: "O", x: 3, y: 3})
    png = ActiveCrossword.render_errors(active_crossword)
    :egd.save(png, "test3.png")
    assert png == TestHelper.test_crossword_errors_png
  end

  test "rendering errors with solutions", %{active_crossword: active_crossword} do
    active_crossword = ActiveCrossword.add_answer(active_crossword, %Answer{letter: "B", x: 1, y: 2})
    active_crossword = ActiveCrossword.add_answer(active_crossword, %Answer{letter: "O", x: 3, y: 3})
    png = ActiveCrossword.render_errors(active_crossword, true)
    :egd.save(png, "test4.png")
    assert png == TestHelper.test_crossword_solution_png
  end

  test "checking if solved", %{active_crossword: active_crossword} do
    answers = [
      {"C", 1, 1}, {"A", 1, 2}, {"P", 1, 3},
      {"A", 2, 1}, {"N", 2, 2}, {"T", 2, 3},
      {"T", 3, 1}
    ]
    active_crossword = Enum.reduce(answers, active_crossword, fn({letter, x, y}, a_c) ->
      ActiveCrossword.add_answer(a_c, %Answer{letter: letter, x: x, y: y})
    end)
    assert not ActiveCrossword.solved?(active_crossword)
    active_crossword = ActiveCrossword.add_answer(active_crossword, %Answer{letter: "O", x: 3, y: 3})
    assert ActiveCrossword.solved?(active_crossword)
  end

end
