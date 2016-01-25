defmodule Slackword.Crossword.ParserTest do
  use ExUnit.Case, async: true

  alias Slackword.Crossword

  setup do
    {:ok, crossword: TestHelper.test_crossword}
  end

  test "metadata", %{crossword: crossword} do
    assert crossword.metadata.title == "Test Crossword"
    assert crossword.metadata.creator == "Rohan"
    assert crossword.metadata.copyright == "2016 Rohan"
  end

  test "grid", %{crossword: crossword} do
    assert crossword.grid.dimensions == {3, 3}
    top_left = Crossword.get(crossword, 1, 1)
    assert top_left.number == "1"
    assert top_left.solution == "C"
    assert top_left.x == 1
    assert top_left.y == 1
    assert Crossword.block?(top_left) == false
    block = Crossword.get(crossword, 3, 2)
    assert Crossword.block?(block) == true
    assert block.x == 3
    assert block.y == 2
    bottom_right = Crossword.get(crossword, 3, 3)
    assert bottom_right.number == ""
    assert bottom_right.solution == "O"
    assert Crossword.block?(bottom_right) == false
  end

  test "clues", %{crossword: crossword} do
    assert length(crossword.clues_across) == 3
    assert length(crossword.clues_down) == 2
    assert hd(crossword.clues_across).format == "3"
    assert hd(crossword.clues_down).text == "On your head"
    word = Crossword.get_word(crossword, {"2", :down})
    assert word.direction == :down
    assert word.x_range == 2..2
    assert word.y_range == 1..3
  end
  
end
