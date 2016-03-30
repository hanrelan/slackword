defmodule Slackword.Crossword.Downloaders.MervDownloader do
  @behaviour Slackword.Crossword.Downloader
  use Timex

  def get_url(date, filename) do
    date = get_sunday(date)
    get_js_url(date) |> get_xml
  end

  def save_dir(), do: "merv"

  def get_filename(%DateTime{} = date) do
    date = get_sunday(date)
    {:ok, formatted_date} = date |> DateFormat.format("%y%m%d", :strftime)
    "merv#{formatted_date}.xml"
  end

  defp get_js_url(date) do
    base_url = "http://www.sundaycrosswords.com/ccpuz/"
    path = get_path(date)
    url = "#{base_url}#{path}"
    response = HTTPotion.get url
    html = response.body
    [[puzzle_name]] = Regex.scan(~r/"([^.\d"]+)\d+\.pdf"/, html, capture: :all_but_first)
    [[full_puzzle_name]] = Regex.scan(~r/"(#{puzzle_name}[^.]+)\.js"/, html, capture: :all_but_first)
    "#{base_url}#{full_puzzle_name}.js"
  end

  defp get_xml(js_url) do
    response = HTTPotion.get js_url
    [[xml]] = Regex.scan(~r/(<\?xml.+)";$/, response.body, capture: :all_but_first)
    xml |> String.replace("\\\"", "\"")
  end

  defp get_path(date) do
    weeks_ago = get_weeks_ago(date)
    cond do
      weeks_ago < 4 and weeks_ago >= 1 ->
        "MPuz#{weeks_ago |> Float.floor |> round}WO.php"
      weeks_ago < 1 ->
        "MPuz.php"
    end
  end

  defp get_weeks_ago(date) do
    today = Date.now
    diff = Date.diff(date, today, :days)

    diff/7.0
  end

  defp get_sunday(date) do
   if Date.weekday(date) == 7 do
     date
   else
     get_sunday(date |> Date.shift(days: -1))
   end
  end
end
