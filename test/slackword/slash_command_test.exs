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

  test "sets the command" do
    conn = create_conn(text: "1a cat")
    assert conn.state == :sent
    assert conn.assigns[:command] == "1a"
    assert conn.assigns[:arguments] == ["cat"]
  end

  #  test "sets the server for some commands" do
  #    conn = create_conn
  #    assert conn.state == :sent
  #    assert conn.assigns[:server] == nil
  #
  #    create_conn(text: "new", channel_id: "channel1")
  #    conn = create_conn(text: "clues", channel_id: "channel1")
  #    refute conn.assigns[:server] == nil
  #  end

  defp create_conn(params \\ %{}) do
    merged_map = Dict.merge(%{token: @token, text: "test", team_id: "team", channel_id: "channel"}, params)
    conn = conn(:post, "/cw", merged_map)
           |>  put_req_header("content-type", "application/x-www-form-urlencoded")
    SlashCommand.call(conn, @opts)
  end

end
