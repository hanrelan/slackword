defmodule Slackword.Downloader do
  use Timex

  def get(%DateTime{} = date) do
    {:ok, formatted_date} = date |> DateFormat.format("%y%m%d", :strftime)
    filename = "la#{formatted_date}.xml"
    case get_file(filename) do
      {:ok, file} -> file
      {:error, _} -> get_url(filename)
    end
  end

  defp get_url(filename) do
    url = "http://cdn.games.arkadiumhosted.com/latimes/assets/DailyCrossword/#{filename}"
    response = HTTPotion.get url
    :ok = File.write "crosswords/#{filename}", response.body
    response.body
  end

  defp get_file(filename) do
    File.read "crosswords/#{filename}"
  end
end
