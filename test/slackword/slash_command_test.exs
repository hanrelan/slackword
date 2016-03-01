defmodule Slackword.SlashCommandTest do
  # TODO(rohan): need to create a separate process that loads fonts for concurrency reasons
  use ExUnit.Case, async: false
  use Plug.Test

  alias Slackword.SlashCommand

  @opts SlashCommand.init([])

  @token Application.get_env :slackword, :slack_api_token

  test "requires a matching token" do
    conn = create_conn(token: "abc")
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "fail"

    conn = create_conn
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "hi!"
  end

  test "sets the channel id" do
    conn = create_conn
    assert conn.state == :sent
    assert conn.assigns[:channel_id] == "team_channel"
  end

  test "sets the command and arguments" do
    create_conn(text: "new", channel_id: "channel0")
    conn = create_conn(text: "1a cat", channel_id: "channel0")
    assert conn.state == :sent
    assert conn.assigns[:command] == "1a"
    assert conn.assigns[:arguments] == ["cat"]
  end

  test "sets the server for some commands" do
    conn = create_conn
    assert conn.state == :sent
    assert conn.assigns[:server] == nil
  
    create_conn(text: "new", channel_id: "channel1")
    conn = create_conn(text: "1a cat", channel_id: "channel1")
    refute conn.assigns[:server] == nil
  end

  test "cannot guess without a crossword" do
    conn = create_conn(text: "1a cat", channel_id: "channel2")
    assert conn.resp_body == "You need to start a new crossword first"
  end

  test "old crosswords are loaded if the server is stopped" do
    create_conn(text: "new", channel_id: "channel3")
    conn = create_conn(text: "1a cat", channel_id: "channel3")
    Slackword.Server.stop(conn.assigns[:server])
    conn = create_conn(text: "1a cat", channel_id: "channel3")
    assert conn.state == :sent
    {:ok, response} = Poison.Parser.parse(conn.resp_body)
    assert Map.has_key?(response, "attachments")
  end

  defp create_conn(params \\ %{}) do
    merged_map = Dict.merge(%{token: @token, text: "test", team_id: "team", channel_id: "channel"}, params)
    conn = conn(:post, "/cw", merged_map)
           |>  put_req_header("content-type", "application/x-www-form-urlencoded")
    SlashCommand.call(conn, @opts)
  end

end
