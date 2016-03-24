defmodule Slackword.Crossword.Parsers.AcrossliteParser do
  alias Slackword.{Crossword, Grid}
  alias Slackword.Crossword.{Metadata}

  def parse(<<_checksum::little-integer-size(16), "ACROSS&DOWN\0", 
              _cib_checksum::little-integer-size(16), _masked_low_checksum::size(32), _marked_high_checksum::size(32),
              _version_string::binary-size(3),  0::size(8), _reserved1c::size(16), _scrambled_checksum::little-integer-size(16), 
              _reserved20::binary-size(12), width::size(8), height::size(8), num_clues::little-integer-size(16), _bitmask::size(16),
              _scrambled_tag::little-integer-size(16),
              rest::binary>>) do
    grid_size = width*height
    <<board_state::binary-size(grid_size), _player_state::binary-size(grid_size), rest::binary>> = rest
    {title, rest} = get_string(rest)
    {author, rest} = get_string(rest)
    {copyright, rest} = get_string(rest)
    {clues, rest} = Enum.reduce(1..num_clues, {[], rest}, fn _i, {clues, rest} -> 
      {clue, rest} = get_string(rest)
      {[clue | clues], rest}
    end)
    clues = Enum.reverse(clues) 
    {notes, rest} = get_string(rest)
    metadata = Metadata.new(%{title: title, creator: author, copyright: copyright, description: notes})
    {board_grid, _} = Enum.reduce(String.codepoints(board_state), {%Grid{dimensions: {width, height}}, 1}, fn letter, {grid, loc} ->
      {Grid.add(grid, div(loc, width) + 1, rem(loc, height) + 1, letter), loc + 1}
    end)
    IO.inspect board_state
    IO.puts Grid.get(board_grid, 1, 1)
    IO.puts Grid.get(board_grid, 1, 2)
    IO.puts Grid.get(board_grid, 2, 1)
    IO.puts Grid.get(board_grid, 2, 2)
  end

  defp get_string(binary) do
    [bin, rest] = :binary.split(binary, <<0::size(8)>>)
    {:ok, str} = Codepagex.to_string(bin, :iso_8859_1)
    {str, rest}
  end

end
