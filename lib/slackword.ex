defmodule Slackword do
  use Application

  def start(_type, _args) do
    Slackword.Supervisor.start_link
  end

end
