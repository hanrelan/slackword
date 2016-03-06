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
  @timeout 1*60*60*1000 # 1 hour

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

  def get_crossword(server) do
    GenServer.call(server, {:get_crossword})
  end

  def guess_word(server, clue_idx, guess) do
    GenServer.call(server, {:guess_word, clue_idx, guess})
  end

  def load_crossword(server) do
    GenServer.call(server, {:load_crossword})
  end

  def stop(server) do
    GenServer.stop(server)
  end

  defp save_crossword(server) do
    GenServer.cast(server, {:save_crossword})
  end

  ## Server API

  def init(id) do
    {:ok, %{id: id}, @timeout}
  end

  def handle_call({:new_crossword, _date}, _from, %{crossword: _crossword} = state) do
    {:reply, {:error, :already_exists}, state, @timeout}
  end

  def handle_call({:new_crossword, %Timex.DateTime{} = date}, _from, state) do
    crossword = ActiveCrossword.new(Slackword.Crossword.new(date))
    save_crossword(self())
    {:reply, :ok, Map.put(state, :crossword, crossword), @timeout} 
  end

  def handle_call({:get_crossword}, _from, state) do
    With.crossword(state) do
      {:reply, {:ok, crossword}, state, @timeout}
    end
  end

  def handle_call({:guess_word, clue_idx, guess}, _from, state) do
    With.crossword(state) do
      case ActiveCrossword.guess_word(crossword, clue_idx, guess) do
        {:error, error} ->
          {:reply, {:error, error}, state, @timeout}
        {:ok, crossword} ->
          save_crossword(self())
          {:reply, :ok, %{state | crossword: crossword}, @timeout}
      end
    end
  end

  def handle_call({:load_crossword}, _from, %{crossword: _crossword} = state) do
    {:reply, :ok, state, @timeout} 
  end

  def handle_call({:load_crossword}, _from, %{id: id} = state) do
    case Slackword.Database.load_crossword(id) do
      :not_found -> {:reply, {:error, :not_found}, state, @timeout}
      crossword -> {:reply, :ok, Map.put(state, :crossword, crossword), @timeout}
    end
  end

  def handle_cast({:save_crossword}, %{id: id, crossword: crossword} = state) do
    # TODO(rohan): Should eventually only save the answers
    Slackword.Database.save_crossword(id, crossword)
    {:noreply, state, @timeout}
  end

  def handle_info(:timeout, state) do
    {:stop, :normal, state}
  end

end
