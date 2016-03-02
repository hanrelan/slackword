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
  @clue_font_path Slackword.FontHelper.font_path("fixed6x12.wingsfont")
  @padding 5


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
    size = Grid.rendered_size(grid, output_width, output_height)
    image = render_clues(crossword, image, size, output_width, output_height)
    image
  end

  defp render_clues(%Crossword{clues_across: clues_across, clues_down: clues_down}, image, {size_x, size_y}, width, height) do
    bottom_height = height - size_y
    bottom_mid_width = size_x/2 |> trunc
    right_mid_width = (width - size_x)/2 |> trunc
    columns = [{0, size_y, bottom_mid_width, bottom_height},
               {bottom_mid_width, size_y, bottom_mid_width, bottom_height},
               {size_x, 0, right_mid_width, height},
               {right_mid_width + size_x, 0, right_mid_width, height}]
    Enum.each(columns, fn {x, y, w, h} ->
      :egd.line(image, {x + w, y + @padding}, {x + w, y + h - @padding}, @clue_color)
    end)
    all_clues = Enum.concat([["ACROSS"], Enum.map(clues_across, &Clue.render(&1)), 
                   [" "], ["DOWN"], Enum.map(clues_down, &Clue.render(&1))])
    # TODO(rohan): Deal with the situation where all the clues don't render
    {image, []} = Enum.reduce(columns, {image, all_clues}, fn({_x, y, _w, _h} = column, {image, clues_remaining}) ->
      render_into_column(image, clues_remaining, column, y + @padding)
    end)
    image
  end

  defp render_into_column(image, [clue | remaining_clues] = clues, {x, y, w, h} = column, current_y) do
    clue_font = :egd_font.load(@clue_font_path)
    {font_w, font_h} = :egd_font.size(clue_font)
    x = x + @padding
    wrapped_clue = Slackword.StringHelper.wrap_to_lines(clue, w - 10, font_w + 2) 
    clue_height = Enum.count(wrapped_clue) * (font_h + @padding)
    if (clue_height + current_y) > (y + h) do
      {image, clues}
    else
      {image, current_y} = Enum.reduce(wrapped_clue, {image, current_y}, fn(clue, {image, this_y}) ->
        :egd.text(image, {x, this_y}, clue_font, to_char_list(clue), @clue_color)
        this_y = this_y + font_h + @padding
        {image, this_y}
      end)
      render_into_column(image, remaining_clues, column, current_y)
    end
  end

  defp render_into_column(image, [], _, _) do
    {image, []}
  end

end
