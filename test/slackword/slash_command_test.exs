defmodule Slackword.SlashCommandTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias Slackword.SlashCommand

  @opts SlashCommand.init([])

  @token Application.get_env :slackword, :slack_api_token

  test "requires a matching token" do
    conn = conn(:post, "/cw", %{token: "abc", text: "test"})
           |>  put_req_header("content-type", "application/x-www-form-urlencoded")
    conn = SlashCommand.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "fail"

    conn = conn(:post, "/cw", %{token: @token, text: "test"})
           |>  put_req_header("content-type", "application/x-www-form-urlencoded")
    conn = SlashCommand.call(conn, @opts)
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "hi!"
  end

end
