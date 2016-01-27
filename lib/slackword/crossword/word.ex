defmodule Slackword.Crossword.Word do
  defstruct id: "", x_range: 0..0, y_range: 0..0, direction: :across

  alias Slackword.Crossword.Word

  def new(%{id: id, x_range: x_range, y_range: y_range}) do
    word = %Word{id: id, x_range: parse_range(x_range), y_range: parse_range(y_range)}
    direction = if Enum.count(word.y_range) == 1, do: :across, else: :down
    %{word | direction: direction}
  end

  defp parse_range(range) do
    case String.split(range, "-") do
      [num_str] -> 
        {number, _rem} = Integer.parse(num_str)
        number..number
      [start_num_str, end_num_str] ->
        {start_num, _rem} = Integer.parse(start_num_str)
        {end_num, _rem} = Integer.parse(end_num_str)
        start_num..end_num
    end
  end

  def length(%Word{direction: :across, x_range: x_range}), do: Enum.count(x_range)
  def length(%Word{direction: :down, y_range: y_range}), do: Enum.count(y_range)

  def indexes(%Word{direction: :across, x_range: x_range, y_range: y..y}) do
    Enum.map(x_range, &({&1, y}))
  end
  def indexes(%Word{direction: :down, y_range: y_range, x_range: x..x}) do
    Enum.map(y_range, &({x, &1}))
  end

end
