defmodule Slackword.ActiveCrossword.Answer do
  alias Slackword.ActiveCrossword.Answer
  alias Slackword.GridSquare
  defstruct letter: "", x: 0, y: 0

  @letter_color :egd.color(:black)

  def render_to_image(%Answer{letter: letter} = answer, image, %{box_width: box_width, letter_font: letter_font}) do
    GridSquare.render_letter_to_image(image, {answer.x, answer.y}, letter, box_width, %{letter_font: letter_font, letter_color: @letter_color})
  end

end

defmodule Slackword.ActiveCrossword do
  alias Slackword.{Crossword, Grid, ActiveCrossword}
  alias Slackword.ActiveCrossword.Answer
  alias Slackword.Crossword.{Cell, Word}

  defstruct crossword: %Crossword{}, answers: %Grid{}

  @letter_font_path Path.join(["privstatic", "fonts", "osx", "Terminus16.wingsfont"])

  def new(%Crossword{grid: grid} = crossword) do
    %ActiveCrossword{crossword: crossword, answers: %Grid{dimensions: grid.dimensions}}
  end

  def add_answer(%ActiveCrossword{answers: answers} = active_crossword, %Answer{} = answer) do
    answers = Grid.add(answers, answer.x, answer.y, answer) 
    %{active_crossword | answers: answers}
  end

  def get_answer(%ActiveCrossword{answers: answers}, x, y) do
    answer = Grid.get(answers, x, y)
    if answer == nil do
      %Answer{x: x, y: y}
    else
      answer
    end
  end

  def guess_word(%ActiveCrossword{crossword: crossword} = active_crossword, clue_idx, guess) do
    guess_length = String.length(guess)
    word = Crossword.get_word(crossword, clue_idx) 
    word_length = Word.length(word)
    cond do
      word == nil -> {:error, :invalid_word}
      guess_length > word_length -> {:error, {:too_long, word_length, guess_length}}
      guess_length < word_length -> {:error, {:too_short, word_length, guess_length}}
      true ->
        guess = String.upcase(guess) |> String.codepoints
        indexed_guesses = Stream.zip(Word.indexes(word), guess)
        active_crossword = Enum.reduce(indexed_guesses, active_crossword, fn({{x, y}, letter}, a_c) -> 
          ActiveCrossword.add_answer(a_c, %Answer{x: x, y: y, letter: letter})
        end)
        {:ok, active_crossword}
    end
  end

  def render(%ActiveCrossword{crossword: crossword, answers: answers}, output_width \\ 400, output_height \\ 500) do
    base_image = Crossword.render(crossword, output_width, output_height)
    box_width = Grid.box_width(answers, output_width, output_height)
    letter_font = :egd_font.load(@letter_font_path)
    Grid.reduce(answers, base_image, fn({_x, _y, answer=%Answer{}}, image) ->
      Answer.render_to_image(answer, image, %{box_width: box_width, letter_font: letter_font})
    end)
    :egd.render(base_image, :png)
  end

  def render_errors(%ActiveCrossword{crossword: crossword, answers: answers} = active_crossword, show_solutions \\ false, output_width \\ 400, output_height \\ 500) do
    base_image = Crossword.render(crossword, output_width, output_height)
    box_width = Grid.box_width(answers, output_width, output_height)
    letter_font = :egd_font.load(@letter_font_path)
    Grid.reduce(crossword.grid, base_image, fn({_x, _y, cell=%Cell{x: x, y: y, solution: solution}}, image) ->
      %Answer{letter: letter} = answer = ActiveCrossword.get_answer(active_crossword, x, y)
      cond do
        Crossword.block?(cell) -> image
        letter == "" and show_solutions == false -> image
        (letter == "" and show_solutions == true) or (letter != solution) ->
          Cell.render_solution(cell, image, %{box_width: box_width, letter_font: letter_font})
        letter == solution ->
          Answer.render_to_image(answer, image, %{box_width: box_width, letter_font: letter_font})
      end 
    end)
    :egd.render(base_image, :png)
  end

  def solved?(%ActiveCrossword{crossword: crossword} = active_crossword) do
    any_errors = false
    any_errors = Grid.reduce(crossword.grid, any_errors, fn({_x, _y, cell=%Cell{x: x, y: y, solution: solution}}, any_errors) ->
      # TODO(rohan): Seems inefficient to destructure active_crossword every time
      # Convert this to use Answer.get_answers instead
      %Answer{letter: letter} = ActiveCrossword.get_answer(active_crossword, x, y)
      cond do
        Crossword.block?(cell) -> any_errors
        letter != solution -> 
          true
        true -> any_errors
      end
    end)
    not any_errors
  end

  def render_clues(%ActiveCrossword{crossword: crossword}) do
    Crossword.render_clues(crossword)
  end

end
