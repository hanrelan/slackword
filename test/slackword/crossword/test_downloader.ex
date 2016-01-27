defmodule Slackword.Crossword.Downloader do
  @static_dir "test/privstatic"
  use Timex

  def get(%DateTime{} = date) do
    get_file("test_crossword.xml")
  end

  defp get_file(filename) do
    File.read! "#{@static_dir}/#{filename}"
  end
end
