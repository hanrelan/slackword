defmodule Slackword.Crossword.Parser do
  alias Slackword.{Crossword, Grid}
  alias Slackword.Crossword.{Metadata, Cell, Word, Clue}
  import SweetXml

  def parse(xml) do
    crossword = %Crossword{}
    parse_metadata(crossword, xml) |> parse_grid(xml) |> parse_clues(xml)
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
                |> Enum.map(fn(cell_map) -> {cell_map.x, cell_map.y, Cell.new(cell_map)} end)
    %{crossword | grid: Grid.new({dimensions.width, dimensions.height}, cells)}
  end

  defp parse_clues(crossword, xml) do
    words = xml |> xpath(~x"//crossword/word"l, id: ~x"./@id"s, x_range: ~x"./@x"s, y_range: ~x"./@y"s)
    words_map = Stream.map(words, &Word.new/1) |> Enum.into(%{}, fn(word) -> {word.id, word} end)
    clues = xml |> xpath(~x"//clue"l, word_id: ~x"./@word"s, number: ~x"./@number"s, format: ~x"./@format"s, text: ~x"./text()"s) 
                |> Enum.map(fn(clue_map) -> Clue.new(clue_map, words_map) end) 
    Crossword.set_clues(crossword, clues)
  end

end
