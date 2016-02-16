defmodule Slackword.Response do

  def handle_command("help") do
    "help -> returns this message"
  end

  def handle_command("test") do
    "hi!"
  end

  def handle_command(cmd) do
    "I don't know how to #{cmd}. Try /cw help instead"
  end

end
