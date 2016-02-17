defmodule Slackword.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      worker(Slackword.Database, []),
      worker(Slackword.Registry, [Slackword.Registry]),
      supervisor(Slackword.ServerSupervisor, [])
    ]
    supervise(children, strategy: :rest_for_one)
  end
end
