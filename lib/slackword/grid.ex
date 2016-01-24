defmodule Slackword.Grid do
  defstruct cells: %{}, dimensions: {0, 0}

  alias Slackword.Grid

  def new(dimensions, cell_list) do
    cells = Enum.reduce(cell_list, %{}, &add_cell/2)
    grid = %Grid{dimensions: dimensions, cells: cells}
  end

  def get(%Grid{cells: cells}, x, y) do
    Map.fetch!(cells, x) |> Map.fetch!(y) 
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
