defmodule MFLRequestTest do
  use ExUnit.Case
  Application.ensure_all_started(:bypass)

  setup do
    %{
      year: "2018",
      bypass: Bypass.open(port: 12171)
    }
  end

  test "token/3 rejects bad passwords", %{year: year, bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      assert "/#{year}/login" == conn.request_path
      assert "USERNAME=user&PASSWORD=wrong_password&XML=1" == conn.query_string
      assert "GET" == conn.method
      Plug.Conn.resp(conn, 200, "no cookie in header")
    end)

    assert MFL.Request.token(year, "user", "wrong_password") == {:error, :not_authenticated}
  end

  test "token/3 accepts good passwords", %{year: year, bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      assert "/#{year}/login" == conn.request_path
      assert "USERNAME=user&PASSWORD=correct_password&XML=1" == conn.query_string
      assert "GET" == conn.method

      Plug.Conn.resp(conn, 200, "auth cookie passed")
      |> Plug.Conn.put_resp_header("Set-Cookie", "ABCD")
    end)

    assert MFL.Request.token(year, "user", "correct_password") == {:ok, "ABCD"}
  end
end
