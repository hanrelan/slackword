ExUnit.start()

defmodule TestHelper do
  @static_dir "test/privstatic"
  def test_crossword_xml do
    {:ok, file} = File.read "#{@static_dir}/test_crossword.xml"
    file
  end

  def test_crossword do
    Slackword.Crossword.Parser.parse(test_crossword_xml)
  end

  def test_crossword_png do
    load_test_crossword("test_crossword.png")
  end

  def test_crossword_answers_png do
    load_test_crossword("test_crossword_answers.png")
  end

  def test_crossword_errors_png do
    load_test_crossword("test_crossword_errors.png")
  end

  def test_crossword_solution_png do
    load_test_crossword("test_crossword_solution.png")
  end

  defp load_test_crossword(filename) do
    {:ok, file} = File.read "#{@static_dir}/#{filename}"
    file
  end
end
