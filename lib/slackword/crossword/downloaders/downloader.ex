defmodule Slackword.Crossword.Downloader do
  @static_dir Application.get_env(:slackword, :private_static_dir)
  use Timex

  @callback get_url(String.t) :: iodata
  @callback save_dir() :: String.t
  @callback get_filename(DateTime.t) :: String.t

  def get(%DateTime{} = date, downloader) do
    filename = downloader.get_filename(date)
    case get_file(downloader.save_dir(), filename) do
      {:ok, file} -> file
      {:error, _} -> 
        new_file = downloader.get_url(filename)
        :ok = File.mkdir_p(Path.join([@static_dir, downloader.save_dir]))
        :ok = File.write(Path.join([@static_dir, downloader.save_dir, filename]), new_file)
        new_file
    end
  end

  defp get_file(save_dir, filename) do
    File.read Path.join([@static_dir, save_dir, filename])
  end

end
