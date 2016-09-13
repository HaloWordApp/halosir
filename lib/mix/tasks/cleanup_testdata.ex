defmodule Mix.Tasks.CleanupTestdata do
  @moduledoc false
  use Mix.Task
  require Logger

  def run(_args) do
    Logger.info "Removing DETS files under test/data/"
    File.rm("test/data/youdao.dets")
    File.rm("test/data/webster.dets")
  end
end
