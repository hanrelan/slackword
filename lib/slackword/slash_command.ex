defmodule Slackword.SlashCommand do
  @public_static_dir Application.get_env(:slackword, :public_static_dir)

  use Plug.Router

  plug Plug.Parsers, parsers: [:urlencoded]
  #plug :validate_token
  plug :set_channel_id
  plug :set_command
  plug :set_server
  plug :match
  plug :dispatch

  alias Slackword.{Database, Response, Registry}

  def start_server do
    Plug.Adapters.Cowboy.http(__MODULE__, nil, port: 3000)
  end

  post "/cw" do
    conn |> handle_command 
  end

  match _ do
    conn |> send_resp(404, "oops")
  end

  defp handle_command(conn) do
    response = Response.handle_command(conn.assigns[:command], conn)
    content_type = "text/plain"
    if is_map(response) do
      response = Poison.Encoder.encode(response, [])
      content_type = "application/json"
    end
    conn |> put_resp_content_type(content_type) |> send_resp(200, response)
  end

  defp validate_token(conn, _) do
    if conn.params["token"] != Application.get_env(:slackword, :slack_api_token) do
      conn |> send_resp(200, "fail") |> halt
    else
      conn
    end
  end

  defp set_command(conn, _) do
    text = conn.params["text"] |> String.strip
    commands = String.split(text, ~r/\s+/)
    conn |> assign(:command, hd(commands)) |> assign(:arguments, tl(commands)) 
  end

  defp set_channel_id(conn, _) do
    channel_id = "#{conn.params["team_id"]}_#{conn.params["channel_id"]}"
    conn |> assign(:channel_id, channel_id)
  end

  defp set_server(conn, _) do
    if set_server_for_command?(conn.assigns[:command]) do
      channel_id = conn.assigns[:channel_id]
      crossword_id = Database.get_game_id(channel_id)
      server = Registry.find_or_create(Slackword.Registry, {channel_id, crossword_id})
      case Slackword.Server.load_crossword(server) do
        :ok -> conn |> assign(:crossword_id, crossword_id) |> assign(:server, server)
        {:error, :not_found} -> conn |> send_resp(200, "You need to start a new crossword first") |> halt
      end
    else
      conn
    end
  end

  defp set_server_for_command?(command) do
    cond do
      command in ["show"] -> true
      Slackword.StringHelper.is_guess?(command) -> true
      true -> false
    end
  end

end
