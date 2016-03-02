defmodule Slackword.StringHelper do

  def is_guess?(text) do
    parse_guess(text) != nil
  end

  def parse_guess(text) do
    captures = Regex.named_captures(~r/(?<number>\d+)(?<direction>a|d)$/i, text)
    if captures == nil do
      nil
    else
      direction = if (captures["direction"] == "a") or (captures["direction"] == "A"), do: :across, else: :down
      {captures["number"], direction}
    end
  end

  # TODO(rohan): handle the case where the word_width > line_width
  def wrap_to_lines(text, line_width, letter_width) do
    words = String.split(text, " ")
    wrap_words(words, [], line_width, [], line_width, letter_width)
  end

  defp wrap_words([word | words_rest] = words, current_line, width_left, result, line_width, letter_width) do
    word_width = String.length(word) * letter_width
    if word_width <= width_left do
      wrap_words(words_rest, [word | current_line], width_left - word_width, result, line_width, letter_width)
    else
      wrap_words(words, [], line_width, [line_to_string(current_line) | result], line_width, letter_width)
    end
  end

  defp wrap_words([], current_line, _width_left, result, _line_width, _letter_width) do
    Enum.reverse([line_to_string(current_line) | result])
  end

  defp line_to_string(line) do
    line |> Enum.reverse |> Enum.join(" ")
  end

end
