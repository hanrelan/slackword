defmodule Slackword.DatabaseTest do
  use ExUnit.Case, async: false

  alias Slackword.Database
  
  setup do
    Database.drop
  end

  test "returns not found for a channel_id that doesn't exist" do
    assert Database.get_game_id("asdf") == :not_found
  end 

  test "new_game_id returns an id of 1 if an id doesn't exist" do
    assert Database.new_game_id("asdf") == 1
    assert Database.get_game_id("asdf") == 1
  end

  test "new_game_id increments the id" do
    assert Database.new_game_id("asdf") == 1
    assert Database.new_game_id("asdf") == 2
    assert Database.get_game_id("asdf") == 2 
  end

  test "set_game_id sets the id" do
    assert Database.new_game_id("asdf") == 1
    assert Database.new_game_id("asdf") == 2
    Database.set_game_id("asdf", 1)
    assert Database.get_game_id("asdf") == 1
  end

  test "new_game_id increments the id to a not used id" do
    assert Database.new_game_id("asdf") == 1
    assert Database.new_game_id("asdf") == 2
    Database.set_game_id("asdf", 1)
    assert Database.new_game_id("asdf") == 3
  end

end
