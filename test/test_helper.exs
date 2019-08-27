ExUnit.start()
Application.ensure_all_started(:bypass)

File.rm("test/data/youdao.dets")
File.rm("test/data/webster.dets")
