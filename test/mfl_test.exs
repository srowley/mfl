defmodule MFLTest do
  use ExUnit.Case
  Application.ensure_all_started(:bypass)

  setup do
    %{
      year: "2018",
      bypass: Bypass.open(port: 12171)
    }
  end

  describe "MFL.players/2" do
    test "valid request", %{year: year, bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        assert "/#{year}/export" == conn.request_path
        assert "TYPE=players&JSON=1" == conn.query_string
        assert "GET" == conn.method

        Plug.Conn.resp(
          conn,
          200,
          ~s<{"version":"1.0","players":{"timestamp":"1549725469","player":[{"position":"RB","name":"Nix, Roosevelt","id":"4397","team":"PIT"},{"position":"RB","name":"Johnson, David","id":"12171","team":"ARI"}]},"encoding":"utf-8"}>
        )
      end)

      assert MFL.players(year) == [
               %{"position" => "RB", "name" => "Nix, Roosevelt", "id" => "4397", "team" => "PIT"},
               %{"position" => "RB", "name" => "Johnson, David", "id" => "12171", "team" => "ARI"}
             ]
    end

    test "nonsense data for year", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        assert "/blah/export" == conn.request_path
        assert "TYPE=players&JSON=1" == conn.query_string
        assert "GET" == conn.method
        Plug.Conn.resp(conn, 404, "Not Found.")
      end)

      assert MFL.players("blah") == %{error: "MFL returned 'not found'; check year."}
    end
  end
end
