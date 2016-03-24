colors = (System.get_env("VIMRUNTIME") == nil)
ExUnit.start(colors: [enabled: colors])

defmodule TestHelper do
  @static_dir Application.get_env(:slackword, :private_static_dir)

  def test_crossword do
    Slackword.Crossword.new(Timex.Date.now, Slackword.Crossword.Downloaders.TestDownloader)
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
