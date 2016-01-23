defmodule Slackword.Crossword.Cell do
  defstruct type: :block, number: "", solution: "", answer: "", x: 0, y: 0

  alias Slackword.Crossword.Cell

  def new(%{type: "block", x: x, y: y}) do
    %Cell{x: x, y: y}
  end

  def new(cell_map) do
    cell = Map.merge(%Cell{}, cell_map)
    %{cell | type: :normal}
  end

  def block?(%Cell{type: :block}), do: true
  def block?(%Cell{type: _}), do: false

  def render_to_image(%Cell{} = cell, image, box_width, block_color) do
    {top_left, bottom_right} = corners(cell, box_width)
    unless block?(cell) do
      :egd.rectangle(image, top_left, bottom_right, block_color)
    else
      :egd.filledRectangle(image, top_left, bottom_right, block_color)
    end
    image
  end

  defp corners(%Cell{x: x, y: y}, box_width) do
    top_left_x = (x - 1) * box_width
    top_left_y = (y - 1) * box_width
    {{top_left_x, top_left_y}, {top_left_x + box_width, top_left_y + box_width}}
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

  def render(%Crossword{grid: grid}, output_width \\ 500, output_height \\ 400) do
    image = :egd.create(output_width, output_height)
    block_color = :egd.color(:black)
    box_width = 
      if Float.floor(output_width/grid.width) <= Float.floor(output_height/grid.height) do
        Float.floor(output_width/grid.width) |> round
      else
        Float.floor(output_height/grid.height) |> round
      end
    Grid.reduce(grid, image, fn({_x, _y, cell = %Cell{}}, image) ->
      Cell.render_to_image(cell, image, box_width, block_color)
    end)
    image
  end

end
