use Mix.Config

config :slackword, :downloader, Slackword.Crossword.TestDownloader
config :slackword, :private_static_dir, Path.join(["test", "privstatic"])
