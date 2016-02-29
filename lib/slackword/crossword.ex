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
  @clue_color :egd.color(:black)
  #@clue_font_path Path.join(["privstatic", "fonts", "osx", "CJK-12.wingsfont"])
  @clue_font_path Path.join(["privstatic", "fonts", "osx", "fixed6x12.wingsfont"])

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

  def render(%Crossword{grid: grid} = crossword, output_width \\ 800, output_height \\ 800) do
    image = :egd.create(output_width, output_height)
    number_font = :egd_font.load(Path.join([:code.priv_dir(:percept), "fonts", "6x11_latin1.wingsfont"]))
    box_width = Grid.box_width(grid, output_width, output_height)
    Grid.reduce(grid, image, fn({_x, _y, cell = %Cell{}}, image) ->
      Cell.render_to_image(cell, image, %{box_width: box_width, number_font: number_font})
    end)
    offset = Grid.right_edge(grid, output_width, output_height)
    image = render_clues(crossword, image, offset, output_width, output_height)
    image
  end

  def render_clues(%Crossword{clues_across: clues_across, clues_down: clues_down}, image, left, width, height) do
    center_x = ((width - left)/2 |> trunc) + left
    :egd.line(image, {center_x, 0}, {center_x, height}, @clue_color)
    render_clues_direction(image, clues_across, 'ACROSS', left, {center_x - left, height})
    render_clues_direction(image, clues_down, 'DOWN', center_x, {width - center_x, height})
    image
  end

  def render_clues_direction(image, clues, header, start_x, {width, height}) do
    clue_font = :egd_font.load(@clue_font_path)
    {font_w, font_h} = :egd_font.size(clue_font)
    current_y = 2
    start_x = start_x + 5
    :egd.text(image, {start_x, current_y}, clue_font, header, @clue_color)
    current_y = current_y + font_h + 5
    wrapped_clues = Stream.flat_map(clues, fn clue -> Clue.render(clue) |> Slackword.StringHelper.wrap_to_lines(width - 10, font_w + 2) end)
    Enum.reduce(wrapped_clues, {image, current_y}, fn(clue, {image, current_y}) ->
      :egd.text(image, {start_x, current_y}, clue_font, to_char_list(clue), @clue_color)
      current_y = current_y + font_h + 5
      {image, current_y}
    end)
    image
  end

  def get_clues(%Crossword{clues_across: clues_across, clues_down: clues_down}) do
    result = ""
    result = result <> "\n*Across*\n"
    result = result <> get_clues_direction(clues_across)
    result = result <> "*Down*\n"
    result = result <> get_clues_direction(clues_down)
    result
  end

  defp get_clues_direction(clues) do
    Stream.map(clues, &Clue.render(&1)) |> Enum.join("\n")
  end

end
