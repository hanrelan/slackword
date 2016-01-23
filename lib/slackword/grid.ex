defmodule Slackword.Grid do
  defstruct cells: %{}, width: 0, height: 0

  alias Slackword.Grid

  def new({width, height} = _dimensions, cell_list) do
    cells = Enum.reduce(cell_list, %{}, &add_cell/2)
    grid = %Grid{width: width, height: height, cells: cells}
  end

  def get(%Grid{cells: cells}, x, y) do
    Map.fetch!(cells, x) |> Map.fetch!(y) 
  end

  def reduce(%Grid{cells: cells}, acc, fun) do
    Enum.reduce(cells, acc, fn({x_idx, y_map}, acc2) ->
      Enum.reduce(y_map, acc2, fn({y_idx, cell}, acc3) ->
        fun.({x_idx, y_idx, cell}, acc3)
      end)
    end)
  end

  defp add_cell({x, y, cell}, cells) do
    new_x = Map.get(cells, x, %{}) |> Map.put(y, cell)
    Map.put(cells, x, new_x)
  end

end
