defmodule Slackword.Crossword.Cell do
  defstruct type: :block, number: "", solution: "", answer: ""

  alias Slackword.Crossword.Cell

  def new(%{type: "block"}) do
    %Cell{}
  end

  def new(cell_map) do
    cell = Map.merge(%Cell{}, cell_map)
    %{cell | type: :normal}
  end

  def block?(%Cell{type: :block}) do
    true
  end

  def block?(%Cell{type: _}) do
    false
  end
end

defmodule Slackword.Crossword.Grid do
  defstruct cells: %HashDict{}, width: 0, height: 0

  alias Slackword.Crossword.Cell

  def new(dimensions, cell_list) do
    grid = Map.merge(%Slackword.Crossword.Grid{}, dimensions)
    cells = Enum.reduce(cell_list, HashDict.new, &add_cell/2)
    %{grid | cells: cells}
  end

  def get(%Slackword.Crossword.Grid{cells: cells}, x, y) do
    HashDict.fetch!(cells, x) |> HashDict.fetch!(y) 
  end

  defp add_cell(%{x: x, y: y} = cell_map, cells) do
    cell = Cell.new(cell_map)
    new_x = HashDict.get(cells, x, HashDict.new) |> HashDict.put(y, cell)
    HashDict.put(cells, x, new_x)
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
  alias Slackword.Crossword.{Grid, Metadata, Cell}

  defstruct metadata: %Metadata{}, grid: %Grid{}, words: %HashDict{}, clues_across: [], clues_down: []

  def new(%Timex.DateTime{} = date) do
    Slackword.Downloader.get(date) |> Slackword.Parser.parse
  end

  def get(%Slackword.Crossword{grid: grid}, x, y) do
    Grid.get(grid, x, y)
  end

  def block?(%Cell{} = cell) do
    Cell.block?(cell)
  end

end

defmodule Slackword.Parser do
  alias Slackword.Crossword
  alias Slackword.Crossword.{Grid, Metadata}
  import SweetXml

  def parse(xml) do
    crossword = %Crossword{}
    parse_metadata(crossword, xml) |> parse_grid(xml)
  end

  defp parse_metadata(crossword, xml) do
    metadata = xml |> xpath(~x"//metadata", title: ~x"./title/text()"so, creator: ~x"./creator/text()"so, 
                                            copyright: ~x"./copyright/text()"so, description: ~x"./description/text()"so)
    %{crossword | metadata: Metadata.new(metadata)}
  end

  defp parse_grid(crossword, xml) do
    dimensions = xml |> xpath(~x"//grid", width: ~x"./@width"i, height: ~x"./@height"i)
    cells = xml |> xpath(~x"//grid/cell"l, x: ~x"./@x"i, y: ~x"./@y"i, 
                                            solution: ~x"./@solution"so, number: ~x"./@number"so,
                                            type: ~x"./@type"so)
    %{crossword | grid: Grid.new(dimensions, cells)}
  end

end
