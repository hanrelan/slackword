defmodule Slackword.StringHelperTest do
  use ExUnit.Case, async: true

  alias Slackword.StringHelper

  test "correctly wraps" do
    text = "abc def ghij"
    assert StringHelper.wrap_to_lines(text, 4, 1) == ["abc", "def", "ghij"]
    assert StringHelper.wrap_to_lines(text, 6, 1) == ["abc def", "ghij"]
    assert StringHelper.wrap_to_lines(text, 12, 2) == ["abc def", "ghij"]
  end

end
