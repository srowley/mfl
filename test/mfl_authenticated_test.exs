defmodule MFLAuthenticatedTest do
  use ExUnit.Case
  Application.ensure_all_started(:bypass)

  alias MFL.Authenticated

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
      assert {"cookie", "MFL_USER_ID=TOKEN"} in conn.req_headers

      Plug.Conn.resp(conn, 200, response_body)
    end)
  end

  test "no token", %{year: year, league: league} do
    assert Authenticated.calendar(year, league, []) == {:error, "Must provide authentication token as first option."}
  end

  test "invalid token", %{year: year, league: league, bypass: bypass} do
    body = ~s<{"version":"1.0","error":{"$t":"API requires logged in user in league ID #{league}- Please be sure to pass the proper MFL_USER_ID cookie or APIKEY parameter"},"encoding":"utf-8"}>

    bypass_success_expectation(bypass, league, year, "calendar", body)

    assert Authenticated.calendar(year, league, token: "TOKEN") == {:error, "API requires logged in user in league ID 42618- Please be sure to pass the proper MFL_USER_ID cookie or APIKEY parameter"}
  end

  test "accounting/3", %{year: year, league: league, bypass: bypass} do
    body = ~s<{"version":"1.0","accounting":{"entry":[{"amount":"300","timestamp":"1532501469","franchise_id":"0010","id":"37374291","description":"Paid"}]},"encoding":"utf-8"}>

    bypass_success_expectation(bypass, league, year, "accounting", body)
    assert Authenticated.accounting(year, league, token: "TOKEN") == [
      %{
        "amount" => "300",
        "timestamp" => "1532501469",
        "franchise_id" => "0010",
        "id" => "37374291",
        "description" => "Paid"
      }
    ]
  end

  test "calendar/3", %{year: year, league: league, bypass: bypass} do
    body = ~s<{"version":"1.0","calendar":{"event":[{"end_time":"","happens":"","start_time":"1535418000","title":"","type":"AUCTION_START","id":"5442532"}]},"encoding":"utf-8"}>

    bypass_success_expectation(bypass, league, year, "calendar", body)

    assert Authenticated.calendar(year, league, token: "TOKEN") == [
      %{
        "end_time" => "",
        "happens" => "",
        "start_time" => "1535418000",
        "title" => "",
        "type" => "AUCTION_START",
        "id" => "5442532"
      }
    ] 
  end

  test "my_watch_list/3", %{year: year, league: league, bypass: bypass} do
    body = ~s<{"version":"1.0","myWatchList":{"player":[{"id":"10517"}]},"encoding":"utf-8"}>
    bypass_success_expectation(bypass, league, year, "myWatchList", body)
    assert Authenticated.my_watch_list(year, league, token: "TOKEN") == ["10517"] 
  end

  test "assets/3", %{year: year, league: league, bypass: bypass} do
    body = ~s<{"assets":{"franchise":[{"futureYearDraftPicks":{"draftPick":[{"pick":"FP_0001_2019_1","description":"Year 2019 Round 1 from 2 Gurleys"}]},"blindBiddingDollars":{"amount":"51.00"},"players":{"player":[{"id":"12141"}]},"id":"0001"}]},"version":"1.0","encoding":"utf-8"}>

    bypass_success_expectation(bypass, league, year, "assets", body)
    assert Authenticated.assets(year, league, token: "TOKEN") == [
      %{
        "id" => "0001",
        "futureYearDraftPicks" => %{
          "draftPick" => [
            %{
              "pick" => "FP_0001_2019_1",
              "description" => "Year 2019 Round 1 from 2 Gurleys"
            }
          ]
        },
        "blindBiddingDollars" => %{
          "amount" => "51.00"
        },
        "players" => %{
          "player" => [
            %{
              "id" => "12141"
            }
          ]
        }
      }
    ]
  end

  test "polls/3", %{year: year, league: league, bypass: bypass} do
    body = ~s<{"polls":{"poll":[{"question":"Taxi Squad Players","answer":[{"text":"Rookies Only","id":"2834818","votes":"2"},{"text":"Rookies & Vets","id":"2834819","votes":"3"}],"multiple_choice":"0","author":"0001","id":"701508","hasVoted":"1","expires":"1495735200"}]},"version":"1.0","encoding":"utf-8"}>

    bypass_success_expectation(bypass, league, year, "polls", body)
    assert Authenticated.polls(year, league, token: "TOKEN") == [
      %{
        "question" => "Taxi Squad Players",
        "answer" => [
          %{
            "text" => "Rookies Only",
            "id" => "2834818",
            "votes" => "2"
          },
          %{
            "text" => "Rookies & Vets",
            "id" => "2834819",
            "votes" => "3"
          }
        ],
        "multiple_choice" => "0",
        "author" => "0001",
        "id" => "701508",
        "hasVoted" => "1",
        "expires" => "1495735200"
      }
    ]    
  end

  test "salary_adjustments/3", %{year: year, league: league, bypass: bypass} do
    body = ~s<{"version":"1.0","salaryAdjustments":{"salaryAdjustment":[{"amount":"2.00","timestamp":"1373254913","franchise_id":"0001","id":"0","description":"kept of wright's salary after trade"}]},"encoding":"utf-8"}> 

    bypass_success_expectation(bypass, league, year, "salaryAdjustments", body)
    assert Authenticated.salary_adjustments(year, league, token: "TOKEN") == [
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
