use Mix.Config

config :slackword, :default_downloader, Slackword.Crossword.Downloaders.TestDownloader
config :slackword, :private_static_dir, Path.join(["test", "privstatic"])
config :slackword, :public_static_dir, Path.join(["test", "public"])
config :slackword, :slack_api_token, "test_api_token"
config :slackword, :db_dir, Path.join(["test", "db"])
