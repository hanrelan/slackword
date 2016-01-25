defmodule Slackword.Crossword.WordTest do
  use ExUnit.Case, async: true

  alias Slackword.Crossword.Word

  test "new" do
    word = Word.new(%{id: "1", x_range: "1-3", y_range: "2"})
    assert word.x_range == {1, 3}
    assert word.y_range == {2, 2}
    assert word.id == "1"
  end

  test "across and down" do
    word = Word.new(%{id: "1", x_range: "1-3", y_range: "2"})
    assert word.direction == :across
    word = Word.new(%{id: "1", x_range: "1", y_range: "2-3"})
    assert word.direction == :down
  end
end
