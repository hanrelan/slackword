defmodule Slackword.RegistryTest do
  use ExUnit.Case, async: true

  alias Slackword.{Registry, Server}
  alias Slackword.Crossword.Downloaders.TestDownloader

  setup context do
    {:ok, registry} = Registry.start_link(context.test)
    {:ok, registry: registry}
  end

  test "spawns a server if it doesn't exist", %{registry: registry} do
    server = Registry.find_or_create(registry, "1")
    assert Server.new_crossword(server, Timex.Date.now, TestDownloader) == :ok
  end

  test "returns an existing server if it exists", %{registry: registry} do
    server = Registry.find_or_create(registry, "1")
    server2 = Registry.find_or_create(registry, "1")
    assert server == server2
    server3 = Registry.find_or_create(registry, "2")
    assert server != server3
  end

  test "stopping a server removes it from the registry", %{registry: registry} do
    server = Registry.find_or_create(registry, "1")
    Server.stop(server)
    server2 = Registry.find_or_create(registry, "1")
    assert server != server2
  end

  test "crashed server is removed from the registry", %{registry: registry} do
    server = Registry.find_or_create(registry, "1")
    ref = Process.monitor(server)
    Process.exit(server, :shutdown)
    assert_receive {:DOWN, ^ref, _, _, _}
    server2 = Registry.find_or_create(registry, "1")
    assert server != server2
  end

end
