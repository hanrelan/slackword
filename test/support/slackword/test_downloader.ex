defmodule Slackword.Crossword.Downloaders.TestDownloader do
  @behaviour Slackword.Crossword.Downloader

  def get_url(_date, _filename) do
    raise "Can't retrieve from URL"
    ""
  end

  def save_dir(), do: ""

  def get_filename(%Timex.DateTime{} = _date), do: "test_crossword.xml"
end
