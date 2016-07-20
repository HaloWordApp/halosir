defmodule HaloSir.YoudaoControllerTest do
  use HaloSir.ConnCase

  alias Plug.Conn

  setup do
    bypass = Bypass.open

    test_config = [
      api_base: "http://localhost:#{bypass.port}?",
      keyfrom: "testkeyfrom",
      key: "testkey"
    ]

    Application.put_env(:halosir, HaloSir.YoudaoController, test_config)

    {:ok, %{bypass: bypass}}
  end

  test "Query cached word should return cached result without hitting external service", %{bypass: bypass} do
    :dets.insert(:youdao, {"test", "test cached result", 1})
    Bypass.down(bypass)

    conn = get build_conn(), "/youdao/query/test"
    assert conn.resp_body =~ "test cached result"
  end

  test "Query non-cached word should hit the server, then cache the result", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      conn = Conn.fetch_query_params(conn)
      assert conn.query_params["q"] == "test"
      assert conn.method == "GET"

      Conn.resp(conn, 200, "test result to cache")
    end

    :dets.delete(:youdao, "test")

    conn = get build_conn(), "/youdao/query/test"

    assert conn.resp_body =~ "test result to cache"
    assert HaloSir.DetsStore.get(:youdao, "test") == {:ok, "test result to cache"}
    assert {"test", "test result to cache", 1} == :dets.lookup(:youdao, "test") |> hd
  end

  test "When configured proxy, use the proxy to fetch result", %{bypass: bypass} do
    proxy_config = [
      proxy: "http://localhost:#{bypass.port}/youdao/query/"
    ]

    Application.put_env(:halosir, HaloSir.YoudaoController, proxy_config)

    Bypass.expect bypass, fn conn ->
      assert conn.request_path == "/youdao/query/test"
      assert conn.method == "GET"

      Conn.resp(conn, 200, "test result from proxy")
    end

    :dets.delete(:youdao, "test")

    conn = get build_conn(), "/youdao/query/test"

    assert conn.resp_body =~ "test result from proxy"
    assert HaloSir.DetsStore.get(:youdao, "test") == {:ok, "test result from proxy"}
    assert {"test", "test result from proxy", 1} == :dets.lookup(:youdao, "test") |> hd
  end
end
