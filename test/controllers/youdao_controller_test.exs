defmodule HaloSirWeb.YoudaoControllerTest do
  use HaloSirWeb.ConnCase

  alias Plug.Conn

  setup do
    bypass = Bypass.open()

    test_config = [
      api_base: "http://localhost:#{bypass.port}?",
      keyfrom: "testkeyfrom",
      key: "testkey"
    ]

    Application.put_env(:halosir, HaloSirWeb.YoudaoController, test_config)

    {:ok, %{bypass: bypass}}
  end

  test "Query cached word should return cached result without hitting external service", %{
    bypass: bypass
  } do
    :dets.insert(:youdao, {"test", "test cached result", 1})
    Bypass.down(bypass)

    conn = get(build_conn(), "/youdao/query/test")
    assert conn.resp_body =~ "test cached result"

    assert_headers(conn)
  end

  test "Query non-cached word should hit the server, then cache the result", %{bypass: bypass} do
    json_body = ~s({"query":"test","errorCode":0})

    Bypass.expect(bypass, fn conn ->
      conn = Conn.fetch_query_params(conn)
      assert conn.query_params["q"] == "test"
      assert conn.method == "GET"

      Conn.resp(conn, 200, json_body)
    end)

    :dets.delete(:youdao, "test")

    conn = get(build_conn(), "/youdao/query/test")

    assert conn.resp_body =~ json_body
    assert HaloSir.DetsStore.get(:youdao, "test") == {:ok, json_body}
    assert {"test", json_body, 1} == :dets.lookup(:youdao, "test") |> hd

    assert_headers(conn)
  end

  test "When configured proxy, use the proxy to fetch result", %{bypass: bypass} do
    proxy_config = [
      proxy: "http://localhost:#{bypass.port}/youdao/query/"
    ]

    Application.put_env(:halosir, HaloSirWeb.YoudaoController, proxy_config)

    json_body = ~s({"query":"test","errorCode":0})

    Bypass.expect(bypass, fn conn ->
      assert conn.request_path == "/youdao/query/test"
      assert conn.method == "GET"

      Conn.resp(conn, 200, json_body)
    end)

    :dets.delete(:youdao, "test")

    conn = get(build_conn(), "/youdao/query/test")

    assert conn.resp_body =~ json_body
    assert HaloSir.DetsStore.get(:youdao, "test") == {:ok, json_body}
    assert {"test", json_body, 1} == :dets.lookup(:youdao, "test") |> hd

    assert_headers(conn)
  end

  test "Failed query shouldn't be cached, and should return 502 and custom error", %{
    bypass: bypass
  } do
    Bypass.expect(bypass, fn conn ->
      conn = Conn.fetch_query_params(conn)
      assert conn.query_params["q"] == "test"
      assert conn.method == "GET"

      Conn.resp(conn, 500, "Internal Server Error")
    end)

    :dets.delete(:youdao, "test")

    conn = get(build_conn(), "/youdao/query/test")

    assert conn.status == 502
    assert conn.resp_body == "upstream failure"
    assert :dets.lookup(:youdao, "test") == []
  end

  test "Bad query response shouldn't be cached, but should pass-through response", %{
    bypass: bypass
  } do
    json_body = ~s({"query":"test","errorCode":50})

    Bypass.expect(bypass, fn conn ->
      conn = Conn.fetch_query_params(conn)
      assert conn.query_params["q"] == "test"
      assert conn.method == "GET"

      Conn.resp(conn, 200, json_body)
    end)

    :dets.delete(:youdao, "test")

    conn = get(build_conn(), "/youdao/query/test")

    assert conn.status == 200
    assert conn.resp_body == json_body
    assert :dets.lookup(:youdao, "test") == []
  end

  defp assert_headers(conn) do
    headers = Map.new(conn.resp_headers)
    assert Map.get(headers, "cache-control") == Application.get_env(:halosir, :cache_control)
    assert Map.get(headers, "content-type") =~ "application/json"
  end
end
