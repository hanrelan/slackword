defmodule Slackword.CrosswordTest do
  use ExUnit.Case, async: true

  alias Slackword.Crossword
  
  setup do
    {:ok, crossword: TestHelper.test_crossword}
  end

  test "render", %{crossword: crossword} do
    image = Crossword.render(crossword)
    png = :egd.render(image, :png)
    :egd.save(png, "test1.png")
    assert png == TestHelper.test_crossword_png
  end
end
