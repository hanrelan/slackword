defmodule Slackword.Registry do
  use GenServer

  ## Client API
  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def find_or_create(pid, id) do
    GenServer.call(pid, {:find_or_create, id})
  end

  ## Server API

  def init(:ok) do
    servers = %{}
    refs = %{}
    {:ok, {servers, refs}}
  end

  def handle_call({:find_or_create, id}, _from, {servers, refs}) do
    server = servers[id]
    if server == nil do
      {:ok, server} = Slackword.ServerSupervisor.start_server(id)
      ref = Process.monitor(server)
      refs = Map.put(refs, ref, id)
      servers = Map.put(servers, id, server)
    end
    {:reply, server, {servers, refs}}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {servers, refs}) do
    {id, refs} = Map.pop(refs, ref)
    servers = Map.delete(servers, id)
    {:noreply, {servers, refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

end
