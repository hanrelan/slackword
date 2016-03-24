defmodule Slackword.Crossword.Downloaders.LatDownloader do
  @behaviour Slackword.Crossword.Downloader
  use Timex

  def get_url(_date, filename) do
    url = "http://cdn.games.arkadiumhosted.com/latimes/assets/DailyCrossword/#{filename}"
    response = HTTPotion.get url
    response.body
  end

  def save_dir(), do: "lat"

  def get_filename(%DateTime{} = date) do
    {:ok, formatted_date} = date |> DateFormat.format("%y%m%d", :strftime)
    "la#{formatted_date}.xml"
  end

end
