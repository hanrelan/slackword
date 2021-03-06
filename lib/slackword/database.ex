defmodule Slackword.Database do
  @db_file Path.join([Application.get_env(:slackword, :db_dir), "db.cowdb"])

  def start_link do
    Agent.start_link(&init/0, name: __MODULE__)
  end

  def get_game_id(channel_id) do
    cowdb = Agent.get(__MODULE__, &(&1))
    extract_value(:cowdb.get(cowdb, channel_id))
  end

  def new_game_id(channel_id) do
    counter_id = "#{channel_id}:counter"
    Agent.get_and_update(__MODULE__, fn(cowdb) ->
      new_id = case extract_value(:cowdb.get(cowdb, counter_id)) do
        :not_found -> 1
        current_id -> current_id + 1
      end
      :cowdb.put(cowdb, counter_id, new_id)
      :cowdb.put(cowdb, channel_id, new_id)
      {new_id, cowdb}
    end)
  end

  def set_game_id(channel_id, id) do
    Agent.update(__MODULE__, fn(cowdb) ->
      :cowdb.put(cowdb, channel_id, id)
      cowdb
    end)
  end

  def save_crossword(id, crossword) do
    Agent.update(__MODULE__, fn(cowdb) ->
      :cowdb.put(cowdb, id, crossword)
      cowdb
    end)
  end

  def load_crossword(id) do
    cowdb = Agent.get(__MODULE__, &(&1))
    extract_value(:cowdb.get(cowdb, id))
  end

  def drop do
    Agent.update(__MODULE__, fn(cowdb) -> 
      :cowdb.drop_db(cowdb) 
      init
    end)
  end

  defp init do
    {:ok, cowdb} = :cowdb.open(to_char_list(@db_file)) 
    cowdb
  end

  defp extract_value(cowdb_return) do
    case cowdb_return do
      :not_found -> :not_found
      {:ok, {_key, value}} -> value
    end
  end

end
