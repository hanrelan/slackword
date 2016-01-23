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
    assert crossword.grid.width == 3
    assert crossword.grid.height == 3
    top_left = Crossword.get(crossword, 1, 1)
    assert top_left.number == "1"
    assert top_left.solution == "C"
    assert top_left.answer == ""
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
    assert bottom_right.answer == ""
    assert Crossword.block?(bottom_right) == false
  end

end
