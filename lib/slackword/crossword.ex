defmodule Slackword.Crossword.Cell do
  defstruct type: :block, number: "", solution: "", x: 0, y: 0

  @block_color :egd.color(:black)
  @number_color :egd.color(:gray)
  @letter_color :egd.color(:blue)

  alias Slackword.Crossword.Cell
  alias Slackword.GridSquare

  def new(%{type: "block", x: x, y: y}) do
    %Cell{x: x, y: y}
  end

  def new(cell_map) do
    cell = Map.merge(%Cell{}, cell_map)
    %{cell | type: :normal}
  end

  def block?(%Cell{type: :block}), do: true
  def block?(%Cell{type: _}), do: false

  def render_to_image(%Cell{} = cell, image, settings) do
    {top_left, bottom_right} = GridSquare.corners({cell.x, cell.y}, settings.box_width)
    unless block?(cell) do
      :egd.rectangle(image, top_left, bottom_right, @block_color)
      {top_left_x, top_left_y} = top_left
      unless String.length(cell.number) == 0 do
        :egd.text(image, {top_left_x + 2, top_left_y}, settings.number_font, String.to_char_list("#{cell.number}"), @number_color)
      end
    else
      :egd.filledRectangle(image, top_left, bottom_right, @block_color)
    end
    image
  end

  def render_solution(%Cell{} = cell, image, %{box_width: box_width, letter_font: letter_font}) do
    GridSquare.render_letter_to_image(image, {cell.x, cell.y}, cell.solution, box_width, %{letter_font: letter_font, letter_color: @letter_color})
  end

end

defmodule Slackword.Crossword.Metadata do
  defstruct title: "", creator: "", copyright: "", description: ""

  def new(metadata) do
    Map.merge(%Slackword.Crossword.Metadata{}, metadata)
  end
end

defmodule Slack.Crossword.Clue do
  defstruct word: nil, number: nil, format: nil
end

defmodule Slackword.Crossword do
  alias Slackword.{Crossword, Grid}
  alias Slackword.Crossword.{Metadata, Cell}

  defstruct metadata: %Metadata{}, grid: %Grid{}, words: %{}, clues_across: [], clues_down: []

  def new(%Timex.DateTime{} = date) do
    Slackword.Downloader.get(date) |> Slackword.Parser.parse
  end

  def get(%Crossword{grid: grid}, x, y) do
    Grid.get(grid, x, y)
  end

  def block?(%Cell{} = cell) do
    Cell.block?(cell)
  end

  def render(%Crossword{grid: grid}, output_width \\ 400, output_height \\ 500) do
    image = :egd.create(output_width, output_height)
    number_font = :egd_font.load(Path.join([:code.priv_dir(:percept), "fonts", "6x11_latin1.wingsfont"]))
    box_width = Grid.box_width(grid, output_width, output_height)
    Grid.reduce(grid, image, fn({_x, _y, cell = %Cell{}}, image) ->
      Cell.render_to_image(cell, image, %{box_width: box_width, number_font: number_font})
    end)
    image
  end

end
