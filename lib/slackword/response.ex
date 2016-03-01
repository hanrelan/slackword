defmodule Slackword.Response do
  @public_images_dir Path.join([Application.get_env(:slackword, :public_static_dir), "images"])

  alias Slackword.{ActiveCrossword, Database, Registry, Server}

  def handle_command("new", conn) do
    channel_id = conn.assigns[:channel_id]
    args = conn.assigns[:arguments]
    date = case args do
      [] -> Timex.Date.now
      # TODO(rohan): Handle the case where it didn't parse properly
      [date_string] -> Timex.DateFormat.parse!(date_string, "{YYYY}-{M}-{D}")
    end
    crossword_id = Database.new_game_id(channel_id)
    server = Registry.find_or_create(Slackword.Registry, {channel_id, crossword_id})
    :ok = Server.new_crossword(server, date)
    render_crossword(server, conn)
  end

  def handle_command("help", _conn) do
    "help -> returns this message"
  end

  def handle_command("test", _conn) do
    "hi!"
  end

  def handle_command("show", conn) do
    server = conn.assigns[:server]
    render_crossword(server, conn)
  end

  def handle_command(cmd, conn) do
    parsed_guess = Slackword.StringHelper.parse_guess(cmd)
    if parsed_guess != nil do
      handle_guess(parsed_guess, conn)
    else
      "I don't know how to #{cmd}. Try /cw help instead"
    end
  end

  defp handle_guess(clue_idx, conn) do
    server = conn.assigns[:server]
    arguments = conn.assigns[:arguments]
    guess = Enum.join(arguments, "") |> String.replace("_", " ")
    case Server.guess_word(server, clue_idx, guess) do
      {:error, {:too_long, word_length, guess_length}} -> 
      # TODO(rohan): Properly pluralize
        %{response_type: "in_channel", text: "\"#{guess}\" is #{guess_length - word_length} letters too long"}
      {:error, {:too_short, word_length, guess_length}} -> 
        %{response_type: "in_channel", text: "\"#{guess}\" is #{word_length - guess_length} letters too short"}
      :ok -> render_crossword(server, conn)
    end
  end

  defp render_crossword(server, conn, _options \\ []) do
    channel_id = conn.assigns[:channel_id]
    crossword_id = conn.assigns[:crossword_id]
    {:ok, crossword} = Server.get_crossword(server)
    png = ActiveCrossword.render(crossword, 750, 750)
    filename = png_filename(channel_id, crossword_id, crossword)
    :egd.save(png, Path.join([@public_images_dir, filename]))
    %{response_type: "in_channel", 
      attachments: [
        %{image_url: image_url(conn, filename),
          fallback: "Crossword",
          title: "Crossword",
          title_link: image_url(conn, filename)
         }
      ]
     }
  end

  defp png_filename(channel_id, crossword_id, crossword) do
    "#{channel_id}_#{crossword_id}_#{crossword.id}.png"
  end

  defp image_url(conn, filename) do
    # TODO(rohan): the port should come from the conn
    "http://#{conn.host}:8000/images/#{filename}"
  end

end
