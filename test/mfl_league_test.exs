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

  defp bypass_success_expectation(bypass, league, year, type, response_body) do
    Bypass.expect_once(bypass, fn conn ->
      assert "/#{year}/export" == conn.request_path
      assert "TYPE=#{type}&L=#{league}&JSON=1" == conn.query_string
      assert "GET" == conn.method

      Plug.Conn.resp(conn, 200, response_body)
    end)
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

  test "rules/3", %{league: league, year: year, bypass: bypass} do
    body = ~s<{"version":"1.0","rules":{"positionRules":[{"positions":"Def","rule":[{"points":{"$t":"10"},"range":{"$t":"0-0"},"event":{"$t":"STPA+OPA"}},{"points":{"$t":"7"},"range":{"$t":"1-7"},"event":{"$t":"STPA+OPA"}}]},{"positions":"QB|RB|WR|TE","rule":[{"points":{"$t":"*4"},"range":{"$t":"0-99"},"event":{"$t":"#P"}},{"points":{"$t":".05/1"},"range":{"$t":"-100-999"},"event":{"$t":"PY"}}]},{"positions":"TE","rule":{"points":{"$t":"*1"},"range":{"$t":"0-99"},"event":{"$t":"CC"}}}]},"encoding":"utf-8"}>
    bypass_success_expectation(bypass, league, year, "rules", body)
    assert League.rules(year, league) == [
      %{
        "positions" => "Def",
        "rule" => [
          %{
            "points" => "10",
            "range" => "0-0",
            "event" => "STPA+OPA"
          },
          %{
            "points" => "7",
            "range" => "1-7",
            "event" => "STPA+OPA"
          }
        ]
      },
      %{
        "positions" => "QB|RB|WR|TE",
        "rule" => [
          %{
            "points" => "*4",
            "range" => "0-99",
            "event" => "#P"
          },
          %{
            "points" => ".05/1",
            "range" => "-100-999",
            "event" => "PY"
          }
        ]
      },
      %{
        "positions" => "TE",
        "rule" => %{
          "points" => "*1",
          "range" => "0-99",
          "event" => "CC"
        }
      }
    ]  
  end

  test "rosters/3", %{league: league, year: year, bypass: bypass} do
    body = ~s<{"rosters":{"franchise":[{"player":[{"contractYear":"6","contractStatus":"3G-2019R","status":"ROSTER","id":"13146","contractInfo":"2018: $3 kept by Chad in trade","salary":"4"},{"contractYear":"35","contractStatus":"5L-2020E","status":"ROSTER","id":"9902","contractInfo":"2016:  Extended for three years (originally 3L-2017) to 5L-2020","salary":"2.00"}],"id":"0001"},{"player":[{"contractYear":"26","contractStatus":"6L-2020R","status":"ROSTER","id":"12141","contractInfo":"","salary":"26"},{"contractYear":"1","contractStatus":"5G-2022R","status":"TAXI_SQUAD","id":"13776","contractInfo":"","salary":"1"}],"id":"0002"}]},"version":"1.0","encoding":"utf-8"}>

    bypass_success_expectation(bypass, league, year, "rosters", body)

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

  test "salaries/3", %{league: league, year: year, bypass: bypass} do
    body = ~s<{"salaries":{"leagueUnit":{"unit":"LEAGUE","player":[{"contractYear":"","contractStatus":"","id":"0000","contractInfo":"","salary":"0.00"},{"contractYear":"19","contractStatus":"4L-2020E","id":"12155","contractInfo":"Extended","salary":"13"}]}},"version":"1.0","encoding":"utf-8"}>
    
    bypass_success_expectation(bypass, league, year, "salaries", body)

    assert League.salaries(year, league) == [
      %{
        "contractYear" => "",
        "contractStatus" => "",
        "id" => "0000",
        "contractInfo" => "",
        "salary" => "0.00"
      },
      %{
        "contractYear" => "19",
        "contractStatus" => "4L-2020E",
        "id" => "12155",
        "contractInfo" => "Extended",
        "salary" => "13"
      }
    ]
  end

  test "league_standings/3", %{league: league, year: year, bypass: bypass} do
    body = ~s<{"version":"1.0","leagueStandings":{"franchise":[{"h2hl":"2","power_rank":"41.81","dp":"173.00","pf":"2191.06","streak_len":"5","conft":"0","acct":"0","pa":"1620.22","maxpa":"205.6","h2ht":"0","id":"0007","all_play_l":"50","h2hw":"11","all_play_w":"126","confw":"0","confl":"0","altpwr":"34","vp":"47","pp":"2570.64","pwr":"41.81","divw":"0","minpa":"86.2","divl":"0","all_play_t":"0","streak_type":"W","op":"2018.06","divt":"0"},{"h2hl":"3","power_rank":"43.51","dp":"197.00","pf":"2398.80","streak_len":"7","conft":"0","acct":"0","pa":"1456.08","maxpa":"170.44","h2ht":"0","id":"0011","all_play_l":"38","h2hw":"10","all_play_w":"138","confl":"0","confw":"0","altpwr":"35","vp":"46","pp":"2662.56","pwr":"43.51","divw":"0","minpa":"0","divl":"0","all_play_t":"0","streak_type":"W","divt":"0","op":"2201.80"}]},"encoding":"utf-8"}>

    bypass_success_expectation(bypass, league, year, "leagueStandings", body)

    assert League.league_standings(year, league) == [
      %{
        "h2hl" => "2",
        "power_rank" => "41.81",
        "dp" => "173.00",
        "pf" => "2191.06",
        "streak_len" => "5",
        "conft" => "0",
        "acct" => "0",
        "pa" => "1620.22",
        "maxpa" => "205.6",
        "h2ht" => "0",
        "id" => "0007",
        "all_play_l" => "50",
        "h2hw" => "11",
        "all_play_w" => "126",
        "confw" => "0",
        "confl" => "0",
        "altpwr" => "34",
        "vp" => "47",
        "pp" => "2570.64",
        "pwr" => "41.81",
        "divw" => "0",
        "minpa" => "86.2",
        "divl" => "0",
        "all_play_t" => "0",
        "streak_type" => "W",
        "op" => "2018.06",
        "divt" => "0"
      },
      %{
        "h2hl" => "3",
        "power_rank" => "43.51",
        "dp" => "197.00",
        "pf" => "2398.80",
        "streak_len" => "7",
        "conft" => "0",
        "acct" => "0",
        "pa" => "1456.08",
        "maxpa" => "170.44",
        "h2ht" => "0",
        "id" => "0011",
        "all_play_l" => "38",
        "h2hw" => "10",
        "all_play_w" => "138",
        "confw" => "0",
        "confl" => "0",
        "altpwr" => "35",
        "vp" => "46",
        "pp" => "2662.56",
        "pwr" => "43.51",
        "divw" => "0",
        "minpa" => "0",
        "divl" => "0",
        "all_play_t" => "0",
        "streak_type" => "W",
        "op" => "2201.80",
        "divt" => "0"
      }
    ]
  end

  test "schedule/3", %{league: league, year: year, bypass: bypass} do
    body = ~s<{"version":"1.0","schedule":{"weeklySchedule":[{"matchup":[{"franchise":[{"isHome":"0","score":"148","id":"0005","result":"W"},{"isHome":"1","score":"128","id":"0003","result":"L"}]}],"week":"16"},{"week":"17"}]},"encoding":"utf-8"}>

    bypass_success_expectation(bypass, league, year, "schedule", body)
    assert League.schedule(year, league) == [
      %{
        "week" => "16",
        "matchup" => [
          %{
            "franchise" => [
              %{
                "isHome" => "0",
                "score" => "148",
                "id" => "0005",
                "result" => "W"
              },
              %{
                "isHome" => "1",
                "score" => "128",
                "id" => "0003",
                "result" => "L"
              }
            ]
          }
        ]
      },
      %{"week" => "17"}
    ]
  end

  test "weekly_results/3", %{league: league, year: year, bypass: bypass} do
    body = ~s<{"version":"1.0","weeklyResults":{"franchise":[{"player":[{"status":"starter","id":"11674","shouldStart":"1","score":"23"}],"optimal":"12140,11674,","score":"143","comments":"Best Lineup","opt_pts":"143","starters":"12140,11674,","id":"0001","nonstarters":"13319,13391,"}],"week":"17"},"encoding":"utf-8"}>

    bypass_success_expectation(bypass, league, year, "weeklyResults", body)

    assert League.weekly_results(year, league) == %{
      "franchise" => [
        %{
          "player" => [
            %{
              "status" => "starter",
              "id" => "11674",
              "shouldStart" => "1",
              "score" => "23"
            }
          ],
          "optimal" => "12140,11674,",
          "score" => "143",
          "comments" => "Best Lineup",
          "opt_pts" => "143",
          "starters" => "12140,11674,",
          "id" => "0001",
          "nonstarters" => "13319,13391,"
        }
      ],
      "week" => "17"
    }
  end

  test "live_scoring/3", %{league: league, year: year, bypass: bypass} do
    body = ~s<{"liveScoring":{"matchup":[{"franchise":[{"playersCurrentlyPlaying":"0","gameSecondsRemaining":"0","isHome":"0","players":{"player":[{"gameSecondsRemaining":"0","status":"nonstarter","updatedStats":"","score":"0","id":"12211"}]},"playersYetToPlay":"0","score":"179","id":"0005"}]}], "week":"17"},"version":"1.0","encoding":"utf-8"}>

    bypass_success_expectation(bypass, league, year, "liveScoring", body)
    assert League.live_scoring(year, league) == %{
      "matchup" => [
        %{
          "franchise" => [
            %{
              "playersCurrentlyPlaying" => "0",
              "gameSecondsRemaining" => "0",
              "isHome" => "0",
              "players" => %{
                "player" => [
                  %{
                    "gameSecondsRemaining" => "0",
                    "status" => "nonstarter",
                    "updatedStats" => "",
                    "score" => "0",
                    "id" => "12211"
                  }
                ]
              },
              "playersYetToPlay" => "0",
              "score" => "179",
              "id" => "0005"
            }
          ]
        }  
      ],
      "week" => "17"
    }
  end

  describe "player_scores/3" do
    test "when week is not specified", %{league: league, year: year, bypass: bypass} do
      body = ~s<{"playerScores":{"playerScore":[{"week":"1","score":"8.20","id":"8658"}]},"version":"1.0","encoding":"utf-8"}>

      bypass_success_expectation(bypass, league, year, "playerScores", body)
      assert League.player_scores(year, league) ==  %{
        "playerScore" => [
          %{
            "week" => "1",
            "score" => "8.20",
            "id" => "8658",
          }
        ]
      }
    end

    test "when week is specified", %{league: league, year: year, bypass: bypass} do
      body = ~s<{"playerScores":{"week":"12","playerScore":[{"isAvailable":"0","score":"50.20","id":"10703"}]},"version":"1.0","encoding":"utf-8"}>
      Bypass.expect_once(bypass, fn conn ->
        assert "/#{year}/export" == conn.request_path
        assert "TYPE=playerScores&W=12&L=#{league}&JSON=1" == conn.query_string
        assert "GET" == conn.method

        Plug.Conn.resp(conn, 200, body)
      end)

      assert League.player_scores(year, league, w: "12") == %{
        "week" => "12",
        "playerScore" => [
          %{
            "isAvailable" => "0",
            "score" => "50.20",
            "id" => "10703"
          }
        ]
      }
    end
  end

  test "draft_results/3", %{league: league, year: year, bypass: bypass} do
    body = ~s<{"draftResults":{"draftUnit":{"unit":"LEAGUE","draftType":"SDRAFT","draftPick":[{"timestamp":"1536019300","franchise":"0009","round":"01","player":"12150","pick":"01","comments":""}],"round1DraftOrder":"0009,0008,0002,0001,0004,0012,0005,0007,0011,0006,0003,0010,"}},"version":"1.0","encoding":"utf-8"}>

    bypass_success_expectation(bypass, league, year, "draftResults", body)
    assert League.draft_results(year, league) == %{
      "unit" => "LEAGUE",
      "draftType" => "SDRAFT",
      "draftPick" => [
        %{
          "timestamp" => "1536019300",
          "franchise" => "0009",
          "round" => "01",
          "player" => "12150",
          "pick" => "01",
          "comments" => ""
        }
      ],
      "round1DraftOrder" => "0009,0008,0002,0001,0004,0012,0005,0007,0011,0006,0003,0010,"
    }
  end

  test "future_draft_picks/3", %{league: league, year: year, bypass: bypass} do
    body = ~s<{"version":"1.0","futureDraftPicks":{"franchise":[{"futureDraftPick":[{"round":"1","originalPickFor":"0001","year":"2019"}],"id":"0008"}]},"encoding":"utf-8"}>

    bypass_success_expectation(bypass, league, year, "futureDraftPicks", body)
    assert League.future_draft_picks(year, league) == [
      %{
        "id" => "0008",
        "futureDraftPick" => [
          %{
            "round" => "1",
            "originalPickFor" => "0001",
            "year" => "2019"
          }
        ]
      }
    ]
  end

  test "auction_results/3", %{league: league, year: year, bypass: bypass} do
    body = ~s<{"version":"1.0","auctionResults":{"auctionUnit":{"auction":[{"lastBidTime":"1526347741","franchise":"0012","player":"13590","timeStarted":"1526347701","winningBid":"42"}],"unit":"LEAGUE"}},"encoding":"utf-8"}>

    bypass_success_expectation(bypass, league, year, "auctionResults", body)
    assert League.auction_results(year, league) == [
      %{
        "lastBidTime" => "1526347741",
        "franchise" => "0012",
        "player" => "13590",
        "timeStarted" => "1526347701",
        "winningBid" => "42"
      }
    ] 
  end

  test "free_agents/3", %{league: league, year: year, bypass: bypass} do
    body = ~s<{"freeAgents":{"leagueUnit":{"unit":"LEAGUE","player":[{"contractYear":"","contractStatus":"","id":"11682","contractInfo":"","salary":"0.00"},{"contractYear":"","contractStatus":"","id":"12681","contractInfo":"","salary":"0.00"}]}},"version":"1.0","encoding":"utf-8"}>

    bypass_success_expectation(bypass, league, year, "freeAgents", body)
    assert League.free_agents(year, league) == ["11682", "12681"]
  end

  test "transactions/3", %{league: league, year: year, bypass: bypass} do
    body = ~s<{"version":"1.0","transactions":{"transaction":[{"timestamp":"1550025518","franchise":"0003","transaction":"|12617,","type":"FREE_AGENT"},{"activated":"11760,11660,8670,11688,8416,","timestamp":"1546148485","franchise":"0001","deactivated":"","type":"IR"}]},"encoding":"utf-8"}>

    bypass_success_expectation(bypass, league, year, "transactions", body)
    assert League.transactions(year, league) == [
      %{
        "timestamp" => "1550025518",
        "franchise" => "0003",
        "transaction" => "|12617,",
        "type" => "FREE_AGENT"
      },
      %{
        "activated" => "11760,11660,8670,11688,8416,",
        "timestamp" => "1546148485",
        "franchise" => "0001",
        "deactivated" => "",
        "type" => "IR"
      }
    ]
  end

  test "projected_scores/3", %{league: league, year: year, bypass: bypass} do
    body = ~s<{"projectedScores":{"week":"13","playerScore":{"score":"17","id":"12171"}},"version":"1.0","encoding":"utf-8"}>

    bypass_success_expectation(bypass, league, year, "projectedScores", body)
    assert League.projected_scores(year, league) == %{
      "week" => "13",
      "playerScore" => %{
        "score" => "17",
        "id" => "12171"
      }
    }
  end

  test "message_board/3", %{league: league, year: year, bypass: bypass} do
    body = ~s<{"version":"1.0","messageBoard":{"thread":[{"franchise_id":"0000","lastPostTime":"1441332551","subject":"DRAFT DAY IS SATURDAY BE THERE AT 9:30!!","id":"4416836"}]},"encoding":"utf-8"}>

    bypass_success_expectation(bypass, league, year, "messageBoard", body)
    assert League.message_board(year, league) == [
      %{
        "franchise_id" => "0000",
        "lastPostTime" => "1441332551",
        "subject" => "DRAFT DAY IS SATURDAY BE THERE AT 9:30!!",
        "id" => "4416836"
      }
    ]
  end

  test "message_board_thread/4", %{league: league, year: year, bypass: bypass} do
    body = ~s<{"version":"1.0","messageBoardThread":{"post":[{"body":"As per my last message","franchise":"0000","postTime":"1434592222"}]},"encoding":"utf-8"}>

    Bypass.expect_once(bypass, fn conn ->
      assert "/#{year}/export" == conn.request_path
      assert "TYPE=messageBoardThread&THREAD=4357644&L=#{league}&JSON=1" == conn.query_string
      assert "GET" == conn.method

      Plug.Conn.resp(conn, 200, body)
    end)

    assert League.message_board_thread(year, league, "4357644") == [
      %{
        "body" => "As per my last message",
        "franchise" => "0000",
        "postTime" => "1434592222"
      }
    ]
  end

  describe "player_status/4" do
    test "with one player passed", %{league: league, year: year, bypass: bypass} do
      body = ~s<{"version":"1.0","playerStatus":{"status":"Undisclosed Injury - S","id":"12171"},"encoding":"utf-8"}>

      Bypass.expect_once(bypass, fn conn ->
        assert "/#{year}/export" == conn.request_path
        assert "TYPE=playerStatus&P=12171&L=#{league}&JSON=1" == conn.query_string
        assert "GET" == conn.method

        Plug.Conn.resp(conn, 200, body)
      end)

      assert League.player_status(year, league, ["12171"]) == %{
        "status" => "Undisclosed Injury - S",
        "id" => "12171"
      }
    end

    test "with multiple players passed/4", %{league: league, year: year, bypass: bypass} do
      body = ~s"""
      {"playerStatuses":{"playerStatus":[{"status":"Undisclosed Injury - S","id":"12171"},{"status":"Clueless in DC - NS<br  />Free Agent","id":"8658"}]},"version":"1.0","encoding":"utf-8"}
      """

      Bypass.expect_once(bypass, fn conn ->
        assert "/#{year}/export" == conn.request_path
        assert "TYPE=playerStatus&P=12171%2C8658&L=#{league}&JSON=1" == conn.query_string
        assert "GET" == conn.method

        Plug.Conn.resp(conn, 200, body)
      end)

        assert League.player_status(year, league, ["12171", "8658"]) == [
          %{
            "status" => "Undisclosed Injury - S",
            "id" => "12171"
          },
          %{
            "status" => "Clueless in DC - NS<br  />Free Agent",
            "id" => "8658"
          }
        ]
    end
  end

  test "points_allowed/3", %{league: league, year: year, bypass: bypass} do
    body = ~s<{"pointsAllowed":{"team":[{"position":[{"points":"358","name":"RB"},{"points":"264","name":"QB"},{"points":"143","name":"TE"},{"points":"416","name":"WR"}],"id":"MIN"}]},"version":"1.0","encoding":"utf-8"}>
    
    bypass_success_expectation(bypass, league, year, "pointsAllowed", body)

    assert League.points_allowed(year, league) == [
      %{
        "position" => [
          %{
            "points" => "358",
            "name" => "RB"
          },
          %{
            "points" => "264",
            "name" => "QB"
          },
          %{
            "points" => "143",
            "name" => "TE"
          },
          %{
            "points" => "416",
            "name" => "WR"
          }
        ],
        "id" => "MIN"
      }
    ]
  end

  test "pool/3", %{league: league, year: year, bypass: bypass} do
    body = ~s<{"version":"1.0","poolPicks":{"franchise":[{"week":[{"game":[{"matchup":"PIT,NEP","pick":"NEP","rank":"1"}], "week":"1"}],"id":"0001"}],"use_weights":"Pickem","vs_spread":"No","endWeek":"17","type":"NFL","startWeek":"1"},"encoding":"utf-8"}>
    
    bypass_success_expectation(bypass, league, year, "pool", body)

    assert League.pool(year, league) == %{
      "franchise" => [
        %{
          "week" => [
            %{
              "game" => [
                %{
                  "matchup" => "PIT,NEP",
                  "pick" => "NEP",
                  "rank" => "1"
                }
              ],
              "week" => "1",
            }
          ],
          "id" => "0001"
        }
      ],
      "use_weights" => "Pickem",
      "vs_spread" => "No",
      "endWeek" => "17",
      "type" => "NFL",
      "startWeek" => "1"
    }
  end

  test "playoff_brackets/3", %{league: league, year: year, bypass: bypass} do
    body = ~s<{"version":"1.0","playoffBrackets":{"playoffBracket":[{"startWeekGames":"2","name":"Playoffs","startWeek":"14","teamsInvolved":"6","id":"1","bracketWinnerTitle":"Champion"}]},"encoding":"utf-8"}>
    
    bypass_success_expectation(bypass, league, year, "playoffBrackets", body)
    assert League.playoff_brackets(year, league) == [
      %{
        "startWeekGames" => "2",
        "name" => "Playoffs",
        "startWeek" => "14",
        "teamsInvolved" => "6",
        "id" => "1",
        "bracketWinnerTitle" => "Champion"
      }
    ]
  end

  test "appearance/3", %{league: league, year: year, bypass: bypass} do
    body = ~s<{"version":"1.0","appearance":{"skin":"74","tab":[{"name":"Main","id":"0","module":[{"name":"COLUMN=100"}]}]},"encoding":"utf-8"}>
    
    bypass_success_expectation(bypass, league, year, "appearance", body)

    assert League.appearance(year, league) == %{
      "skin" => "74",
      "tab" => [
        %{
          "name" => "Main",
          "id" => "0",
          "module" => [
            %{
              "name" => "COLUMN=100"
            }
          ]
        }
      ]
    } 
  end

  test "salary_adjustments/3", %{league: league, year: year, bypass: bypass} do
    body = ~s<{"version":"1.0","salaryAdjustments":{"salaryAdjustment":[{"amount":"2.00","timestamp":"1373254913","franchise_id":"0001","id":"0","description":"kept of wright's salary after trade"}]},"encoding":"utf-8"}>
    
    bypass_success_expectation(bypass, league, year, "salaryAdjustments", body)

    assert League.salary_adjustments(year, league) == [
     %{
       "amount" => "2.00",
       "timestamp" => "1373254913",
       "franchise_id" => "0001",
       "id" => "0",
       "description" => "kept of wright's salary after trade"
     }
   ]
  end
end
