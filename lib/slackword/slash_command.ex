defmodule Slackword.SlashCommand do
  use Plug.Router

  plug Plug.Parsers, parsers: [:urlencoded]
  plug :validate_token
  plug :set_channel_id
  plug :parse_text
  plug :match
  plug :dispatch

  alias Slackword.Response

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
    response = Response.handle_command(conn.assigns[:command], conn.assigns[:channel_id], conn.assigns[:commands])
    send_resp(conn, 200, response)
  end

  defp validate_token(conn, _) do
    if conn.params["token"] != Application.get_env(:slackword, :slack_api_token) do
      conn |> send_resp(200, "fail") |> halt
    else
      conn
    end
  end

  defp parse_text(conn, _) do
    text = conn.params["text"] |> String.strip
    commands = String.split(text, ~r/\s+/)
    conn |> assign(:command, hd(commands)) |> assign(:commands, commands) 
  end

  defp set_channel_id(conn, _) do
    channel_id = "#{conn.params["team_id"]}:#{conn.params["channel_id"]}"
    conn |> assign(:channel_id, channel_id)
  end

end
