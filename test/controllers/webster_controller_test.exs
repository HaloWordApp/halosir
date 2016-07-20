defmodule HaloSir.WebsterControllerTest do
  use HaloSir.ConnCase

  alias Plug.Conn

  @keys ["test-key1", "test-key2"]

  setup do
    bypass = Bypass.open

    test_config = [
      api_eex: "http://localhost:#{bypass.port}/<%= word %>?key=<%= key %>",
      keys: @keys
    ]

    Application.put_env(:halosir, HaloSir.WebsterController, test_config)

    {:ok, %{bypass: bypass}}
  end

  test "Query cached word should return cached result without hitting external service", %{bypass: bypass} do
    :dets.insert(:webster, {"test", "test cached result", 1})
    Bypass.down(bypass)

    conn = get build_conn(), "/webster/query/test"
    assert conn.resp_body =~ "test cached result"
  end

  test "Query non-cached word should hit the server, then cache the result", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      conn = Conn.fetch_query_params(conn)

      assert conn.query_params["key"] in @keys
      assert conn.request_path == "/test"
      assert conn.method == "GET"

      Conn.resp(conn, 200, "test result to cache")
    end

    :dets.delete(:webster, "test")

    conn = get build_conn(), "/webster/query/test"

    assert conn.resp_body =~ "test result to cache"
    assert HaloSir.DetsStore.get(:webster, "test") == {:ok, "test result to cache"}
    assert {"test", "test result to cache", 1} == :dets.lookup(:webster, "test") |> hd
  end

end
