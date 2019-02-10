defmodule MFLLeagueTest do
  use ExUnit.Case
  Application.ensure_all_started(:bypass)

  alias MFL.League

  setup do
    %{
      league: "42618",
      year: "2018",
      bypass: Bypass.open(port: 12171)
    }
  end

  test "bad league", %{year: year, bypass: bypass} do
    league = "426189"

    Bypass.expect_once(bypass, fn conn ->
      assert "/#{year}/export" == conn.request_path
      assert "TYPE=freeAgents&L=#{league}&JSON=1" == conn.query_string
      assert "GET" == conn.method
      Plug.Conn.resp(conn, 500, "HTTP Server Error.")
    end)

    assert League.free_agents(year, league) == %{error: "MFL server error; check parameters."}
  end

  test "free_agents/3", %{league: league, year: year, bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      assert "/#{year}/export" == conn.request_path
      assert "TYPE=freeAgents&L=#{league}&JSON=1" == conn.query_string
      assert "GET" == conn.method

      Plug.Conn.resp(
        conn,
        200,
        ~s<{"freeAgents":{"leagueUnit":{"unit":"LEAGUE","player":[{"contractYear":"","contractStatus":"","id":"11682","contractInfo":"","salary":"0.00"},{"contractYear":"","contractStatus":"","id":"12681","contractInfo":"","salary":"0.00"}]}},"version":"1.0","encoding":"utf-8"}>
      )
    end)

    assert League.free_agents(year, league) == ["11682", "12681"]
  end

  test "rosters/3", %{league: league, year: year, bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      assert "/#{year}/export" == conn.request_path
      assert "TYPE=rosters&L=#{league}&JSON=1" == conn.query_string
      assert "GET" == conn.method

      Plug.Conn.resp(
        conn,
        200,
        ~s<{"rosters":{"franchise":[{"player":[{"contractYear":"6","contractStatus":"3G-2019R","status":"ROSTER","id":"13146","contractInfo":"2018: $3 kept by Chad in trade","salary":"4"},{"contractYear":"35","contractStatus":"5L-2020E","status":"ROSTER","id":"9902","contractInfo":"2016:  Extended for three years (originally 3L-2017) to 5L-2020","salary":"2.00"}],"id":"0001"},{"player":[{"contractYear":"26","contractStatus":"6L-2020R","status":"ROSTER","id":"12141","contractInfo":"","salary":"26"},{"contractYear":"1","contractStatus":"5G-2022R","status":"TAXI_SQUAD","id":"13776","contractInfo":"","salary":"1"}],"id":"0002"}]},"version":"1.0","encoding":"utf-8"}>
      )
    end)

    assert League.rosters(year, league) == [
             %{
               "player" => [
                 %{
                   "contractYear" => "6",
                   "contractStatus" => "3G-2019R",
                   "status" => "ROSTER",
                   "id" => "13146",
                   "contractInfo" => "2018: $3 kept by Chad in trade",
                   "salary" => "4"
                 },
                 %{
                   "contractYear" => "35",
                   "contractStatus" => "5L-2020E",
                   "status" => "ROSTER",
                   "id" => "9902",
                   "contractInfo" =>
                     "2016:  Extended for three years (originally 3L-2017) to 5L-2020",
                   "salary" => "2.00"
                 }
               ],
               "id" => "0001"
             },
             %{
               "player" => [
                 %{
                   "contractYear" => "26",
                   "contractStatus" => "6L-2020R",
                   "status" => "ROSTER",
                   "id" => "12141",
                   "contractInfo" => "",
                   "salary" => "26"
                 },
                 %{
                   "contractYear" => "1",
                   "contractStatus" => "5G-2022R",
                   "status" => "TAXI_SQUAD",
                   "id" => "13776",
                   "contractInfo" => "",
                   "salary" => "1"
                 }
               ],
               "id" => "0002"
             }
           ]
  end

  test "salary_adjustments/3", %{league: league, year: year, bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      assert "/#{year}/export" == conn.request_path
      assert "TYPE=salaryAdjustments&L=#{league}&JSON=1" == conn.query_string
      assert "GET" == conn.method

      Plug.Conn.resp(
        conn,
        200,
        ~s<{"version":"1.0","salaryAdjustments":{"salaryAdjustment":[{"amount":"2.00","timestamp":"1373254913","franchise_id":"0001","id":"0","description":"kept of wright's salary after trade"},{"amount":"13.00","timestamp":"1447997124","franchise_id":"0003","id":"99","description":"Dropped Anderson in-season"}]},"encoding":"utf-8"}>
      )
    end)

    assert League.salary_adjustments(year, league) == [
             %{
               "amount" => "2.00",
               "timestamp" => "1373254913",
               "franchise_id" => "0001",
               "id" => "0",
               "description" => "kept of wright's salary after trade"
             },
             %{
               "amount" => "13.00",
               "timestamp" => "1447997124",
               "franchise_id" => "0003",
               "id" => "99",
               "description" => "Dropped Anderson in-season"
             }
           ]
  end

  test "league/3", %{league: league, year: year, bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      assert "/#{year}/export" == conn.request_path
      assert "TYPE=league&L=#{league}&JSON=1" == conn.query_string
      assert "GET" == conn.method

      Plug.Conn.resp(
        conn,
        200,
        ~s<{"version":"1.0","league":{"currentWaiverType":"BBID","playerLimitUnit":"LEAGUE","taxiSquad":"4","endWeek":"17","maxWaiverRounds":"8","lockout":"No","auctionStartAmount":"300","franchises":{"count":"12","franchise":[{"icon":"http://b.vimeocdn.com/0.jpg","division":"00","name":"Moonshiners","waiverSortOrder":"5","logo":"http://b.vimeocdn.com/6.jpg","bbidAvailableBalance":"5.00","salaryCapAmount":"","id":"0001"},{"icon":"http://denofgeek.com/over_the_top_main.jpg","abbrev":"HURT","division":"01","name":"Undisclosed Injury","waiverSortOrder":"2","logo":"http://res.cloudbinary.com/a.jpg","bbidAvailableBalance":"0.00","salaryCapAmount":"","id":"0002"}]},"standingsSort":"PCT,PTS,ALL_PLAY_PCT,","draftPlayerPool":"Both","id":"42618","minBid":"1","history":{"league": [{"url":"http://www61.myfantasyleague.com/2018/home/42618","year":"2018"},{"url":"http://www61.myfantasyleague.com/2017/home/42618","year":"2017"}]},"rosterSize":"22","name":"GMFFL","bbidSeasonLimit":"100000","includeIRWithSalary":"100","draftLimitHours":"0:00","starters":{"count":"7-9","position":[{"name":"QB","limit":"1-2"},{"name":"RB","limit":"2-4"},{"name":"WR","limit":"3-5"},{"name":"TE","limit":"1-3"}],"idp_starters":""},"includeTaxiWithSalary":"100","bestLineup":"Yes","precision":"0","lastRegularSeasonWeek":"13","usesContractYear":"1","minKeepers":"0","injuredReserve":"50","bbidConditional":"Yes","startWeek":"1","salaryCapAmount":"300","rostersPerPlayer":"1","h2h":"YES","usesSalaries":"1","maxKeepers":"17","divisions":{"count":"4","division":[{"name":"The Winners","id":"00"},{"name":"At Least We Made the Playoffs","id":"01"},{"name":"Toilet Bowl Betters","id":"02"},{"name":"The Losers","id":"03"}]},"bidIncrement":"1","baseURL":"http://www61.myfantasyleague.com","loadRosters":"live_auction"},"encoding":"utf-8"}>
      )
    end)

    assert League.league(year, league) == %{
             "currentWaiverType" => "BBID",
             "playerLimitUnit" => "LEAGUE",
             "taxiSquad" => "4",
             "endWeek" => "17",
             "maxWaiverRounds" => "8",
             "lockout" => "No",
             "auctionStartAmount" => "300",
             "franchises" => %{
               "count" => "12",
               "franchise" => [
                 %{
                   "icon" => "http://b.vimeocdn.com/0.jpg",
                   "division" => "00",
                   "name" => "Moonshiners",
                   "waiverSortOrder" => "5",
                   "logo" => "http://b.vimeocdn.com/6.jpg",
                   "bbidAvailableBalance" => "5.00",
                   "salaryCapAmount" => "",
                   "id" => "0001"
                 },
                 %{
                   "icon" => "http://denofgeek.com/over_the_top_main.jpg",
                   "abbrev" => "HURT",
                   "division" => "01",
                   "name" => "Undisclosed Injury",
                   "waiverSortOrder" => "2",
                   "logo" => "http://res.cloudbinary.com/a.jpg",
                   "bbidAvailableBalance" => "0.00",
                   "salaryCapAmount" => "",
                   "id" => "0002"
                 }
               ]
             },
             "standingsSort" => "PCT,PTS,ALL_PLAY_PCT,",
             "draftPlayerPool" => "Both",
             "id" => "42618",
             "minBid" => "1",
             "history" => %{
               "league" => [
                 %{
                   "url" => "http://www61.myfantasyleague.com/2018/home/42618",
                   "year" => "2018"
                 },
                 %{
                   "url" => "http://www61.myfantasyleague.com/2017/home/42618",
                   "year" => "2017"
                 }
               ]
             },
             "rosterSize" => "22",
             "name" => "GMFFL",
             "bbidSeasonLimit" => "100000",
             "includeIRWithSalary" => "100",
             "draftLimitHours" => "0:00",
             "starters" => %{
               "count" => "7-9",
               "position" => [
                 %{
                   "name" => "QB",
                   "limit" => "1-2"
                 },
                 %{
                   "name" => "RB",
                   "limit" => "2-4"
                 },
                 %{
                   "name" => "WR",
                   "limit" => "3-5"
                 },
                 %{
                   "name" => "TE",
                   "limit" => "1-3"
                 }
               ],
               "idp_starters" => ""
             },
             "includeTaxiWithSalary" => "100",
             "bestLineup" => "Yes",
             "precision" => "0",
             "lastRegularSeasonWeek" => "13",
             "usesContractYear" => "1",
             "minKeepers" => "0",
             "injuredReserve" => "50",
             "bbidConditional" => "Yes",
             "startWeek" => "1",
             "salaryCapAmount" => "300",
             "rostersPerPlayer" => "1",
             "h2h" => "YES",
             "usesSalaries" => "1",
             "maxKeepers" => "17",
             "divisions" => %{
               "count" => "4",
               "division" => [
                 %{
                   "name" => "The Winners",
                   "id" => "00"
                 },
                 %{
                   "name" => "At Least We Made the Playoffs",
                   "id" => "01"
                 },
                 %{
                   "name" => "Toilet Bowl Betters",
                   "id" => "02"
                 },
                 %{
                   "name" => "The Losers",
                   "id" => "03"
                 }
               ]
             },
             "bidIncrement" => "1",
             "baseURL" => "http://www61.myfantasyleague.com",
             "loadRosters" => "live_auction"
           }
  end
end
