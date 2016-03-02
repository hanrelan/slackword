defmodule Slackword.FontHelper do
  @font_dir Application.get_env :slackword, :font_dir

  def font_path(font_name) do
    Path.join([@font_dir, font_name])
  end

end
