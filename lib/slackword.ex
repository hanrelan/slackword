defmodule Slackword do
  use Application

  def start(_type, _args) do
    response = Slackword.Supervisor.start_link
    Slackword.SlashCommand.start_server
    response
  end

end
