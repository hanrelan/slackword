defmodule Slackword.Crossword.Clue do
  alias Slackword.Crossword.{Clue, Word}
  defstruct word: %Word{}, text: "", number: "", format: "", direction: :across


  def new(%{format: format, number: number, word_id: word_id, text: text}, word_map) do
    %Word{direction: direction} = word = Map.fetch!(word_map, word_id)
    %Clue{format: format, number: number, word: word, direction: direction, text: text} 
  end

  def render(%Clue{text: text, number: number, format: format, word: word}) do
    format = if format == "", do: Word.length(word), else: format
    "#{number}: #{text} (#{format})"
  end

end
