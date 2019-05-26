defmodule MFLTest do
  use ExUnit.Case
  Application.ensure_all_started(:bypass)

  setup do
    %{
      year: "2018",
      bypass: Bypass.open(port: 12171)
    }
  end

  test "all_rules/2", %{year: year, bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      assert "/#{year}/export" == conn.request_path
      assert "TYPE=allRules&JSON=1" == conn.query_string
      assert "GET" == conn.method

      Plug.Conn.resp(
        conn,
        200,
        ~s<{"allRules":{"rule":[{"detailedDescription":{"$t":"This is the total number of Passing TDs in a game by a player or team."},"isTeam":"1","shortDescription":{"$t":"Number of Passing TDs"},"isCoach":"0","isPlayer":"1","abbreviation":{"$t":"#P"}},{"detailedDescription":{"$t":"This is the length in yards of a passing TD in a game.  This rule is evaluated for EACH passing TD in a game."},"isTeam":"1","shortDescription":{"$t":"Length of Passing TD"},"isCoach":"0","isPlayer":"1","abbreviation":{"$t":"PS"}}]},"version":"1.0","encoding":"utf-8"}>
      )
    end)

    assert MFL.all_rules(year) == [
             %{
               "detailedDescription" =>
                 "This is the total number of Passing TDs in a game by a player or team.",
               "isTeam" => "1",
               "shortDescription" => "Number of Passing TDs",
               "isCoach" => "0",
               "isPlayer" => "1",
               "abbreviation" => "#P"
             },
             %{
               "detailedDescription" =>
                 "This is the length in yards of a passing TD in a game.  This rule is evaluated for EACH passing TD in a game.",
               "isTeam" => "1",
               "shortDescription" => "Length of Passing TD",
               "isCoach" => "0",
               "isPlayer" => "1",
               "abbreviation" => "PS"
             }
           ]
  end

  test "injuries/2", %{year: year, bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      assert "/#{year}/export" == conn.request_path
      assert "TYPE=injuries&JSON=1" == conn.query_string
      assert "GET" == conn.method

      Plug.Conn.resp(
        conn,
        200,
        ~S<{"version":"1.0","injuries":{"timestamp":"1549378814","week":"22","injury":[{"status":"IR","id":"10005","details":"Calf\n"},{"status":"Ir-pup","id":"10063","details":"Knee - PCL\n"}]},"encoding":"utf-8"}>
      )
    end)

    assert MFL.injuries(year) == %{
             "timestamp" => "1549378814",
             "week" => "22",
             "injury" => [
               %{
                 "status" => "IR",
                 "id" => "10005",
                 "details" => "Calf\n"
               },
               %{
                 "status" => "Ir-pup",
                 "id" => "10063",
                 "details" => "Knee - PCL\n"
               }
             ]
           }
  end

  test "nfl_schedule/2", %{year: year, bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      assert "/#{year}/export" == conn.request_path
      assert "TYPE=nflSchedule&JSON=1" == conn.query_string
      assert "GET" == conn.method

      Plug.Conn.resp(
        conn,
        200,
        ~s<{"nflSchedule":{"matchup":{"kickoff":"1549236600","gameSecondsRemaining":"0","team":[{"inRedZone":"0","score":"13","hasPossession":"0","passOffenseRank":"5","rushOffenseRank":"5","passDefenseRank":"22","spread":"-2.5","isHome":"0","id":"NEP","rushDefenseRank":"7"},{"inRedZone":"0","score":"3","hasPossession":"0","passOffenseRank":"6","rushOffenseRank":"3","passDefenseRank":"16","spread":"2.5","isHome":"1","id":"LAR","rushDefenseRank":"18"}]},"week":"21"},"encoding":"utf-8"}>
      )
    end)

    assert MFL.nfl_schedule(year) == %{
             "week" => "21",
             "matchup" => %{
               "kickoff" => "1549236600",
               "gameSecondsRemaining" => "0",
               "team" => [
                 %{
                   "inRedZone" => "0",
                   "score" => "13",
                   "hasPossession" => "0",
                   "passOffenseRank" => "5",
                   "rushOffenseRank" => "5",
                   "passDefenseRank" => "22",
                   "rushDefenseRank" => "7",
                   "spread" => "-2.5",
                   "isHome" => "0",
                   "id" => "NEP"
                 },
                 %{
                   "inRedZone" => "0",
                   "score" => "3",
                   "hasPossession" => "0",
                   "passOffenseRank" => "6",
                   "rushOffenseRank" => "3",
                   "passDefenseRank" => "16",
                   "rushDefenseRank" => "18",
                   "spread" => "2.5",
                   "isHome" => "1",
                   "id" => "LAR"
                 }
               ]
             }
           }
  end

  test "nfl_bye_weeks/2", %{year: year, bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      assert "/#{year}/export" == conn.request_path
      assert "TYPE=nflByeWeeks&JSON=1" == conn.query_string
      assert "GET" == conn.method

      Plug.Conn.resp(
        conn,
        200,
        ~s<{"version":"1.0","nflByeWeeks":{"team":[{"bye_week":"9","id":"ARI"},{"bye_week":"8","id":"ATL"}],"year":"2018"},"encoding":"utf-8"}>
      )
    end)

    assert MFL.nfl_bye_weeks(year) == [
             %{
               "bye_week" => "9",
               "id" => "ARI"
             },
             %{
               "bye_week" => "8",
               "id" => "ATL"
             }
           ]
  end

  test "league_search/2", %{year: year, bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      assert "/#{year}/export" == conn.request_path
      assert "TYPE=leagueSearch&SEARCH=LIGA&JSON=1" == conn.query_string
      assert "GET" == conn.method

      Plug.Conn.resp(
        conn,
        200,
        ~s<{"version":"1.0","leagues":{"league":[{"homeURL":"http://www73.myfantasyleague.com/2018/home/10298","name":"La Liga Clone 42","id":"10298"},{"homeURL":"http://www63.myfantasyleague.com/2018/home/10409","name":"Keeper Ligaen 2007","id":"10409"}]},"encoding":"utf-8"}>
      )
    end)

    assert MFL.league_search(year, "liga") == [
             %{
               "homeURL" => "http://www73.myfantasyleague.com/2018/home/10298",
               "name" => "La Liga Clone 42",
               "id" => "10298"
             },
             %{
               "homeURL" => "http://www63.myfantasyleague.com/2018/home/10409",
               "name" => "Keeper Ligaen 2007",
               "id" => "10409"
             }
           ]
  end

  test "player_profile/2", %{year: year, bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      assert "/#{year}/export" == conn.request_path
      assert "TYPE=playerProfile&P=8658&JSON=1" == conn.query_string
      assert "GET" == conn.method

      Plug.Conn.resp(
        conn,
        200,
        ~S<{"playerProfile":{"name":"Peterson, Adrian WAS RB","news":{"article":[{"published":"4 days","id":"410532RotoWire","headline":"Adrian Peterson: Working to stay in Washington"},{"published":"7 days","id":"2019-02-05T12:41:00Rotoworld8658","headline":"WAS has had 'preliminary talks' with Pet..."}]},"player":{"dob":"Mar 21, 1985","adp":"111.08","weight":"220lbs","id":"8658","height":"6' 1\"","age":"33"},"id":"8658"},"version":"1.0","encoding":"utf-8"}>
      )
    end)

    assert MFL.player_profile(year, "8658") == %{
             "name" => "Peterson, Adrian WAS RB",
             "id" => "8658",
             "news" => %{
               "article" => [
                 %{
                   "published" => "4 days",
                   "id" => "410532RotoWire",
                   "headline" => "Adrian Peterson: Working to stay in Washington"
                 },
                 %{
                   "published" => "7 days",
                   "id" => "2019-02-05T12:41:00Rotoworld8658",
                   "headline" => "WAS has had 'preliminary talks' with Pet..."
                 }
               ]
             },
             "player" => %{
               "dob" => "Mar 21, 1985",
               "adp" => "111.08",
               "weight" => "220lbs",
               "id" => "8658",
               "height" => "6' 1\"",
               "age" => "33"
             }
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

      assert MFL.players("blah") == {:error, "MFL returned 'not found'; check year."}
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
