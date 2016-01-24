defmodule Slackword.ActiveCrossword.Answer do
  alias Slackword.ActiveCrossword.Answer
  defstruct letter: "", x: 0, y: 0

  @letter_color :egd.color(:black)

  def render_to_image(%Answer{letter: letter} = answer, image, %{box_width: box_width, letter_font: letter_font}) do
    {letter_w, letter_h} = :egd_font.size(letter_font)
    {{top_left_x, top_left_y}, _} = corners(answer, box_width)
    top_left_x = round((box_width - letter_w)/2) + top_left_x
    top_left_y = round((box_width - letter_h)/2) + top_left_y + 3
    :egd.text(image, {top_left_x, top_left_y}, letter_font, String.to_char_list(letter), @letter_color)
    image
  end

  #TODO(rohan): Put this in a common place or make it a protocol since it's shared with Cell
  defp corners(%Answer{x: x, y: y}, box_width) do
    top_left_x = (x - 1) * box_width
    top_left_y = (y - 1) * box_width
    {{top_left_x, top_left_y}, {top_left_x + box_width, top_left_y + box_width}}
  end
end

defmodule Slackword.ActiveCrossword do
  alias Slackword.{Crossword, Grid, ActiveCrossword}
  alias Slackword.ActiveCrossword.Answer

  defstruct crossword: %Crossword{}, answers: %Grid{}


  def new(%Crossword{grid: grid} = crossword) do
    %ActiveCrossword{crossword: crossword, answers: %Grid{dimensions: grid.dimensions}}
  end

  def add_answer(%ActiveCrossword{answers: answers} = active_crossword, %Answer{} = answer) do
    answers = Grid.add(answers, answer.x, answer.y, answer) 
    %{active_crossword | answers: answers}
  end

  def get_answer(%ActiveCrossword{answers: answers}, x, y) do
    Grid.get(answers, x, y)
  end

  def render_png(%ActiveCrossword{crossword: crossword, answers: answers}, output_width \\ 400, output_height \\ 500) do
    base_image = Crossword.render(crossword, output_width, output_height)
    box_width = Grid.box_width(answers, output_width, output_height)
    letter_font = :egd_font.load(Path.join(["privstatic", "fonts", "osx", "Terminus16.wingsfont"]))
    Grid.reduce(answers, base_image, fn({_x, _y, answer=%Answer{}}, image) ->
      Answer.render_to_image(answer, image, %{box_width: box_width, letter_font: letter_font})
    end)
    :egd.render(base_image, :png)
  end

end
