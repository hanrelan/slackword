defmodule Slackword.Crossword.Metadata do
  defstruct title: "", creator: "", copyright: "", description: ""

  def new(metadata) do
    Map.merge(%Slackword.Crossword.Metadata{}, metadata)
  end
end

defmodule Slackword.Crossword do
  alias Slackword.{Crossword, Grid}
  alias Slackword.Crossword.{Metadata, Cell, Clue}

  @downloader Application.get_env(:slackword, :downloader)

  defstruct metadata: %Metadata{}, grid: %Grid{}, clues: %{}, clues_across: [], clues_down: []

  def new(%Timex.DateTime{} = date) do
    # TODO: handle the case where the downloader fails
    @downloader.get(date) |> Slackword.Crossword.Parser.parse
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

  def render_clues(%Crossword{clues_across: clues_across, clues_down: clues_down}) do
    IO.puts "Across"
    render_clues_direction(clues_across)
    IO.puts "------"
    IO.puts "Down"
    render_clues_direction(clues_down)
  end

  defp render_clues_direction(clues) do
    Enum.each(clues, &(IO.puts Clue.render(&1)))
  end

end
