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
    {:ok, file} = File.read "#{@static_dir}/test_crossword.png"
    file
  end

  def test_crossword_answers_png do
    {:ok, file} = File.read "#{@static_dir}/test_crossword_answers.png"
    file
  end
end
