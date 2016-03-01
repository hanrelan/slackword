defmodule Slackword.ServerTest do
  use ExUnit.Case, async: true
  use Timex

  alias Slackword.Server

  setup do
    {:ok, server} = Server.start_link("1")
    {:ok, server: server}
  end

  test "starting a new crossword should return ok with the crossword", %{server: server} do
    assert :ok == Server.new_crossword(server, Date.now)
  end

  test "starting a new crossword when a crossword has been started should fail", %{server: server} do
    Server.new_crossword(server, Date.now)
    assert Server.new_crossword(server, Date.now) == {:error, :already_exists}
  end

  test "executing commands without a loaded crossword should fail", %{server: server} do
    assert Server.guess_word(server, {"3", :across}, "an") == {:error, :no_crossword}
  end

  test "guess word", %{server: server} do
    Server.new_crossword(server, Date.now)
    assert Server.guess_word(server, {"3", :across}, "ant") == {:error, {:too_long, 2, 3}}
    assert Server.guess_word(server, {"3", :across}, "an") == :ok
  end

  test "loading a crossword with the same id should restore original crossword", %{server: server} do
    Server.new_crossword(server, Date.now)
    Server.stop(server)
    {:ok, server} = Server.start_link("1")
    Server.load_crossword(server)
    assert Server.guess_word(server, {"3", :across}, "an") == :ok
  end

end
