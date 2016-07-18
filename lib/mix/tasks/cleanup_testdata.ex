defmodule Mix.Tasks.CleanupTestdata do
  use Mix.Task

  def run(_args) do
    IO.puts "Removing DETS files under test/data/"
    
    File.rm("test/data/youdao.dets")
    File.rm("test/data/webster.dets")
  end
end
