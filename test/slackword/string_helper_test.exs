defmodule Slackword.StringHelperTest do
  use ExUnit.Case, async: true

  alias Slackword.StringHelper

  test "correctly wraps" do
    text = "abc def ghij"
    assert StringHelper.wrap_to_lines(text, 4, 1) == ["abc", "def", "ghij"]
    assert StringHelper.wrap_to_lines(text, 6, 1) == ["abc def", "ghij"]
    assert StringHelper.wrap_to_lines(text, 12, 2) == ["abc def", "ghij"]
  end

  test "correctly identifies guesses" do
    assert StringHelper.is_guess?("1d") == true
    assert StringHelper.is_guess?("21a") == true
    assert StringHelper.is_guess?("21A") == true
    assert StringHelper.is_guess?("3c") == false
    assert StringHelper.is_guess?("d") == false
  end

  test "correctly parses guesses" do
    assert StringHelper.parse_guess("1d") == {"1", :down}
    assert StringHelper.parse_guess("21a") == {"21", :across}
    assert StringHelper.parse_guess("21A") == {"21", :across}
    assert StringHelper.parse_guess("3c") == nil
    assert StringHelper.parse_guess("d") == nil
  end

end
