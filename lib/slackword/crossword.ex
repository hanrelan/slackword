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

defmodule Slackword.Crossword.Word do
  defstruct id: "", x_range: {0, 0}, y_range: {0, 0}, direction: :across

  alias Slackword.Crossword.Word

  def new(%{id: id, x_range: x_range, y_range: y_range}) do
    word = %Word{id: id, x_range: parse_range(x_range), y_range: parse_range(y_range)}
    direction = case word do
      %Word{y_range: {y, y}} -> :across
      _else -> :down
    end
    %{word | direction: direction}
  end

  defp parse_range(range) do
    case String.split(range, "-") do
      [num_str] -> 
        {number, _rem} = Integer.parse(num_str)
        {number, number}
      [start_num_str, end_num_str] ->
        {start_num, _rem} = Integer.parse(start_num_str)
        {end_num, _rem} = Integer.parse(end_num_str)
        {start_num, end_num}
    end
  end

end

defmodule Slackword.Crossword.Clue do
  alias Slackword.Crossword.{Clue, Word}
  defstruct word: %Word{}, text: "", number: "", format: "", direction: :across


  def new(%{format: format, number: number, word_id: word_id, text: text}, word_map) do
    %Word{direction: direction} = word = Map.fetch!(word_map, word_id)
    %Clue{format: format, number: number, word: word, direction: direction, text: text} 
  end

end

defmodule Slackword.Crossword do
  alias Slackword.{Crossword, Grid}
  alias Slackword.Crossword.{Metadata, Cell, Clue}

  defstruct metadata: %Metadata{}, grid: %Grid{}, clues: %{}, clues_across: [], clues_down: []

  def new(%Timex.DateTime{} = date) do
    Slackword.Downloader.get(date) |> Slackword.Parser.parse
  end

  def get(%Crossword{grid: grid}, x, y) do
    Grid.get(grid, x, y)
  end

  def block?(%Cell{} = cell) do
    Cell.block?(cell)
  end

  def set_clues(%Crossword{} = crossword, clues) do
    {clues_across, clues_down} = Enum.partition(clues, fn(clue) -> clue.direction == :across end)
    clues = Enum.into(clues, %{}, fn(clue) -> {{clue.number, clue.direction}, clue} end)
    %{crossword | clues_across: clues_across, clues_down: clues_down, clues: clues}
  end

  def get_word(%Crossword{clues: clues}, {_number, _direction} = clue_idx) do
    case Map.get(clues, clue_idx) do
      nil -> nil
      %Clue{word: word} -> word
    end
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
