defmodule Slackword.ServerSupervisor do
  use Supervisor

  @name Slackword.ServerSupervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def start_server(id) do
    Supervisor.start_child(@name, [id])
  end

  def init(:ok) do
    children = [
      worker(Slackword.Server, [], restart: :temporary)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end

end
