defmodule Slackword.Response do
  @public_images_dir Path.join([Application.get_env(:slackword, :public_static_dir), "images"])

  alias Slackword.{ActiveCrossword, Database, Registry, Server}

  def handle_command("new", conn) do
    channel_id = conn.assigns[:channel_id]
    crossword_id = Database.new_game_id(channel_id)
    server = Registry.find_or_create(Slackword.Registry, {channel_id, crossword_id})
    {:ok, crossword} = Server.new_crossword(server, Timex.Date.now)
    png = ActiveCrossword.render(crossword, 400, 400)
    filename = png_filename(channel_id, crossword_id, crossword)
    :egd.save(png, Path.join([@public_images_dir, filename]))
    %{response_type: "in_channel", 
      attachments: [
        %{image_url: image_url(conn, filename),
          fallback: "A crossword",
          title: "New crossword",
          title_link: image_url(conn, filename)
        }
      ]
     }
  end

  def handle_command("help", _conn) do
    "help -> returns this message"
  end

  def handle_command("test", _conn) do
    "hi!"
  end

  def handle_command(cmd, _conn) do
    "I don't know how to #{cmd}. Try /cw help instead"
  end

  defp png_filename(channel_id, crossword_id, crossword) do
    "#{channel_id}_#{crossword_id}_#{crossword.id}.png"
  end

  defp image_url(conn, filename) do
    # TODO(rohan): the port should come from the conn
    "http://#{conn.host}:8000/images/#{filename}"
  end

end
