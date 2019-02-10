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

  test "adp/2", %{year: year, bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      assert "/#{year}/export" == conn.request_path
      assert "TYPE=adp&JSON=1" == conn.query_string
      assert "GET" == conn.method

      Plug.Conn.resp(
        conn,
        200,
        ~s<{"adp":{"timestamp":"1549812450","totalDrafts":"8201","player":[{"minPick":"1","maxPick":"163","draftsSelectedIn":"8990","id":"11192","averagePick":"3.04"},{"minPick":"1","maxPick":"188","draftsSelectedIn":"8972","id":"12625","averagePick":"3.85"}]},"version":"1.0","encoding":"utf-8"}>
      )
    end)

    assert MFL.adp(year) == [
      %{
        "minPick" => "1",
        "maxPick" => "163",
        "draftsSelectedIn" => "8990",
        "id" => "11192",
        "averagePick" => "3.04"
      },
      %{
        "minPick" => "1",
        "maxPick" => "188",
        "draftsSelectedIn" => "8972",
        "id" => "12625",
        "averagePick" => "3.85"
      }
    ]
  end

  test "aav/2", %{year: year, bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      assert "/#{year}/export" == conn.request_path
      assert "TYPE=aav&JSON=1" == conn.query_string
      assert "GET" == conn.method

      Plug.Conn.resp(
        conn,
        200,
        ~s<{"aav":{"timestamp":"1549838609","totalAuctions":"78733","player":[{"auctionsSelectedIn":"670","id":"13604","averageValue":"23.45"},{"auctionsSelectedIn":"1","id":"0359","averageValue":"23.33"}]},"version":"1.0","encoding":"utf-8"}>
      )
    end)

    assert MFL.aav(year) == [
      %{
        "auctionsSelectedIn" => "670",
        "id" => "13604",
        "averageValue" => "23.45"
      },
      %{
        "auctionsSelectedIn" => "1",
        "id" => "0359",
        "averageValue" => "23.33"
      }
    ]
  end

  test "top_adds/2", %{year: year, bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      assert "/#{year}/export" == conn.request_path
      assert "TYPE=topAdds&W=2&JSON=1" == conn.query_string
      assert "GET" == conn.method

      Plug.Conn.resp(
        conn,
        200,
        ~s<{"version":"1.0","topAdds":{"week":"2","player":[{"percent":"69.42","id":"13614"},{"percent":"60.21","id":"13763"}]},"encoding":"utf-8"}>
      )
    end)

    assert MFL.top_adds(year, w: "2") == [
      %{
        "id" => "13614",
        "percent" => "69.42"
      },
      %{
        "id" => "13763",
        "percent" => "60.21"
      }
    ]
  end
end
