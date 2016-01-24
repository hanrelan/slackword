defmodule Slackword.GridSquare do

  def corners({x, y}, box_width) do
    top_left_x = (y - 1) * box_width
    top_left_y = (x - 1) * box_width
    {{top_left_x, top_left_y}, {top_left_x + box_width, top_left_y + box_width}}
  end

  def render_letter_to_image(image, point, letter, box_width, %{letter_font: letter_font, letter_color: letter_color}) do
    {letter_w, letter_h} = :egd_font.size(letter_font)
    {{top_left_x, top_left_y}, _} = corners(point, box_width)
    top_left_x = round((box_width - letter_w)/2) + top_left_x
    top_left_y = round((box_width - letter_h)/2) + top_left_y + 3
    :egd.text(image, {top_left_x, top_left_y}, letter_font, String.to_char_list(letter), letter_color)
    image
  end
end

defmodule Slackword.Grid do
  defstruct cells: %{}, dimensions: {0, 0}

  alias Slackword.Grid

  def new(dimensions, cell_list) do
    cells = Enum.reduce(cell_list, %{}, &add_cell/2)
    grid = %Grid{dimensions: dimensions, cells: cells}
  end

  def get(%Grid{cells: cells}, x, y) do
    Map.get(cells, x, %{}) |> Map.get(y) 
  end

  def add(%Grid{cells: cells} = grid, x, y, cell) do
    %{grid | cells: add_cell({x, y, cell}, cells)}
  end

  def reduce(%Grid{cells: cells}, acc, fun) do
    Enum.reduce(cells, acc, fn({x_idx, y_map}, acc2) ->
      Enum.reduce(y_map, acc2, fn({y_idx, cell}, acc3) ->
        fun.({x_idx, y_idx, cell}, acc3)
      end)
    end)
  end

  def box_width(%Grid{dimensions: {width, height}}, output_width, output_height) do
    if Float.floor(output_width/width) <= Float.floor(output_height/height) do
      Float.floor(output_width/width) |> round
    else
      Float.floor(output_height/height) |> round
    end
  end

  defp add_cell({x, y, cell}, cells) do
    new_x = Map.get(cells, x, %{}) |> Map.put(y, cell)
    Map.put(cells, x, new_x)
  end

end
