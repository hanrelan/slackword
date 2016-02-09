defmodule With do

  defmacro crossword(state, expression) do
    do_statement = Keyword.get(expression, :do)
    quote do
      unquoted_state = unquote(state)
      if (var!(crossword) = Map.get(unquoted_state, :crossword)) == nil do
        {:reply, {:error, :no_crossword}, unquoted_state}
      else
        unquote(do_statement)
      end
    end
  end

end

defmodule Slackword.Server do
  use GenServer

  require With

  alias Slackword.ActiveCrossword

  ## Client API

  def start_link(id) do
    GenServer.start_link(__MODULE__, id, [])
  end

  def new_crossword(server, %Timex.DateTime{} = date) do
    GenServer.call(server, {:new_crossword, date})
  end

  def guess_word(server, clue_idx, guess) do
    GenServer.call(server, {:guess_word, clue_idx, guess})
  end

  def stop(server) do
    GenServer.stop(server)
  end

  ## Server API

  def init(id) do
    {:ok, %{id: id}}
  end

  def handle_call({:new_crossword, _date}, _from, %{crossword: crossword} = state) do
    {:reply, {:error, :already_exists}, state}
  end

  def handle_call({:new_crossword, %Timex.DateTime{} = date}, _from, state) do
    crossword = ActiveCrossword.new(Slackword.Crossword.new(date))
    {:reply, :ok, Map.put(state, :crossword, crossword)} 
  end

  def handle_call({:guess_word, clue_idx, guess}, _from, state) do
    With.crossword(state) do
      case ActiveCrossword.guess_word(crossword, clue_idx, guess) do
        {:error, error} ->
          {:reply, {:error, error}, state}
        {:ok, crossword} ->
          {:reply, :ok, %{state | crossword: crossword}}
      end
    end
  end

end
