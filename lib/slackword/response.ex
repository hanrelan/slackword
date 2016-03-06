defmodule Slackword.Response do
  @public_images_dir Path.join([Application.get_env(:slackword, :public_static_dir), "images"])

  alias Slackword.{ActiveCrossword, Database, Registry, Server}

  def handle_command("new", params) do
    channel_id = params[:channel_id]
    args = params[:arguments]
    date = case args do
      [] -> Timex.Date.now
      # TODO(rohan): Handle the case where it didn't parse properly
      [date_string] -> Timex.DateFormat.parse!(date_string, "{YYYY}-{M}-{D}")
    end
    crossword_id = Database.new_game_id(channel_id)
    params = Map.put(params, :crossword_id, crossword_id)
    server = Registry.find_or_create(Slackword.Registry, {channel_id, crossword_id})
    :ok = Server.new_crossword(server, date)
    {:ok, crossword} = Server.get_crossword(server)
    options = %{pretext: crossword.crossword.metadata.title,
                title: "New Crossword ##{crossword_id}"}
    render_crossword(crossword, params, options)
  end

  def handle_command("help", _params) do
    ["help -> returns this message",
     "new -> starts a new crossword from today's LA Times",
     "new YYYY-MM-DD -> starts a new crossword from particular date's LA Times",
     "1a <guess> -> fills in a guess for 1 across",
     "21d <guess> -> fills in a guess for 21 down",
     "show -> shows the current crossword",
     "show errors -> shows any errors",
     "show solution -> show the solution to the current crossword",
     "info -> show the current crossword's title and author"] |> Enum.join("\n")
  end

  def handle_command("test", _params) do
    "hi!"
  end

  def handle_command("show", params) do
    server = params[:server]
    argument = params[:arguments] |> to_string
    {:ok, crossword} = Server.get_crossword(server)
    case argument do
      "" -> render_crossword(crossword, params)
      "errors" -> render_crossword(crossword, params, %{title: "Crossword ##{params[:crossword_id]} Errors"}, 
                                   &ActiveCrossword.render_errors(&1, false, &2, &3)) 
      "solution" -> render_crossword(crossword, params, %{title: "Crossword ##{params[:crossword_id]} Solution"}, 
                                   &ActiveCrossword.render_errors(&1, true, &2, &3)) 
    end
  end

  def handle_command("load", params) do
    argument = params[:arguments] |> to_string
    crossword_id = argument |> Integer.parse
    case crossword_id do
      :error -> "Couldn't parse the crossword id #{argument}"
      {id, _} -> 
        Database.set_game_id(params[:channel_id], id)
        %{response_type: "in_channel", text: "Loaded crossword ##{id}"}
    end
  end

  def handle_command("info", params) do
    server = params[:server]
    {:ok, crossword} = Server.get_crossword(server)
    metadata = crossword.crossword.metadata 
    info = "\n#{metadata.title}\nCreated by #{metadata.creator}\n#{metadata.description}"
    %{response_type: "in_channel", text: info}
  end

  def handle_command(cmd, params) do
    parsed_guess = Slackword.StringHelper.parse_guess(cmd)
    if parsed_guess != nil do
      handle_guess(parsed_guess, params)
    else
      "I don't know how to #{cmd}. Try /cw help instead"
    end
  end

  defp handle_guess(clue_idx, params) do
    server = params[:server]
    arguments = params[:arguments]
    guess = Enum.join(arguments, "") |> String.replace("_", " ")
    case Server.guess_word(server, clue_idx, guess) do
      {:error, :invalid_word} ->
        "That's not one of the clues in this crossword"
      {:error, {:too_long, word_length, guess_length}} -> 
      # TODO(rohan): Properly pluralize
        %{response_type: "in_channel", text: "\"#{guess}\" is #{guess_length - word_length} letters too long"}
      {:error, {:too_short, word_length, guess_length}} -> 
        %{response_type: "in_channel", text: "\"#{guess}\" is #{word_length - guess_length} letters too short"}
      :ok -> 
        {:ok, crossword} = Server.get_crossword(server)
        render_crossword(crossword, params)
    end
  end

  defp render_crossword(crossword, params, options \\ [], render_fun \\ nil) do
    channel_id = params[:channel_id]
    crossword_id = params[:crossword_id]
    png = if render_fun == nil do
      ActiveCrossword.render(crossword, 750, 750)
    else
      render_fun.(crossword, 750, 750)
    end
    if ActiveCrossword.solved?(crossword) do
      options = Dict.merge(%{pretext: "SOLVED!!! :boomgif:"}, options)
    end
    filename = png_filename(channel_id, crossword_id, crossword)
    :egd.save(png, Path.join([@public_images_dir, filename]))
    attachment = 
      Dict.merge(%{image_url: image_url(params, filename),
        fallback: "Crossword #{crossword_id}",
        title: "Crossword ##{crossword_id}",
        title_link: image_url(params, filename),
        }, options)
    %{response_type: "in_channel", 
      attachments: [attachment]
     }
  end

  defp png_filename(channel_id, crossword_id, crossword) do
    "#{channel_id}_#{crossword_id}_#{crossword.id}.png"
  end

  defp image_url(params, filename) do
    "http://#{params[:host]}/images/#{filename}"
  end

end
