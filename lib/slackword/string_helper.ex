defmodule Slackword.StringHelper do

  def wrap_to_lines(text, line_width, letter_width) do
    words = String.split(text, " ")
    wrap_words(words, [], line_width, [], line_width, letter_width)
  end

  defp wrap_words([word | words_rest] = words, current_line, width_left, result, line_width, letter_width) do
    word_width = String.length(word) * letter_width
    if word_width <= width_left do
      wrap_words(words_rest, [word | current_line], width_left - word_width, result, line_width, letter_width)
    else
      current_line_string = current_line |> Enum.reverse |> Enum.join(" ")
      wrap_words(words, [], line_width, [current_line_string | result], line_width, letter_width)
    end
  end

  defp wrap_words([], current_line, _width_left, result, _line_width, _letter_width) do
    current_line_string = current_line |> Enum.reverse |> Enum.join(" ")
    Enum.reverse([current_line_string | result])
  end

end
