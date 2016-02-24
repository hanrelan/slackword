defmodule Slackword.Response do

  alias Slackword.{Database, Registry, Server}

  def handle_command("new", channel_id, _commands) do
    next_game_id = Database.new_game_id(channel_id)
    server = Registry.find_or_create(Slackword.Registry, next_game_id)
    :ok = Server.new_crossword(server, Timex.Date.now)
    "Ok!"
  end

  def handle_command("help", _channel_id, _commands) do
    "help -> returns this message"
  end

  def handle_command("test", _channel_id, _commands) do
    "hi!"
  end

  def handle_command(cmd, _channel_id, _commands) do
    "I don't know how to #{cmd}. Try /cw help instead"
  end

end
