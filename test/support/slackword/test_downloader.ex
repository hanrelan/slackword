defmodule Slackword.Crossword.TestDownloader do
  @static_dir Application.get_env(:slackword, :private_static_dir)
  use Timex

  def get(%DateTime{} = _date) do
    get_file("test_crossword.xml")
  end

  defp get_file(filename) do
    File.read! "#{@static_dir}/#{filename}"
  end
end
