defmodule Tester do

  alias Slackword.ActiveCrossword

  def new do
    {:ok, f} = File.read("privstatic/la160120.xml")
    crossword = Slackword.Crossword.Parser.parse(f)  
    active_crossword = ActiveCrossword.new(crossword)
    show(active_crossword)
    active_crossword
  end

  def show(active_crossword) do
    :egd.save(ActiveCrossword.render(active_crossword), "output.png")
    System.cmd("open", ["output.png"])
    ActiveCrossword.render_clues(active_crossword)
    active_crossword
  end

  def guess(active_crossword, idx, guess) do
    case ActiveCrossword.guess_word(active_crossword, idx, guess) do
      {:ok, ac} -> 
        show(ac)
      {:error, error} -> 
        IO.inspect error
        active_crossword
    end
  end

  def across(active_crossword, number, the_guess) do
    guess(active_crossword, {:across, number}, the_guess)
  end

  def down(active_crossword, number, the_guess) do
    guess(active_crossword, {:down, number}, the_guess)
  end
end
