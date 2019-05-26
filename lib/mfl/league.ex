defmodule MFL.League do
  @moduledoc """
  Wrapper for requests which return information for a specific
  league.

  This module contains functions that make API requests that 
  require a league `id` as an argument.

  The structure for every call is `MFL.League.request_type(year, id, options)`
  where the `id` is a league `id` and the MyFantasyLeague request 
  name is "requestType".

  See the `MFL` module documentation for a discussion of optional 
  request/function parameters.
  """

  import MFL.Request

  @doc """
  Returns league settings data for the specified league.

  Also includes some franchise information and links to previous years'
  home pages for that league.

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=league)
  """
  def league(year, league, options \\ []) do
    retrieve_league_node(["league"], year, league, options)
  end

  @doc """
  Returns league rules for a given league.

  Rules are labelled using abbreviations; descriptions
  for rule abbreviations are available via `MFL.all_rules\2`

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=rules)
  """
  def rules(year, league, options \\ []) do
    records = retrieve_league_node(["rules", "positionRules"], year, league, options)

    case records do
      {:error, message} ->
        {:error, message}

      records ->
        flatten_rules(records)
    end
  end

  @doc """
  Returns rosters (list of players and player data) and franchise
  `id` for each franchise.

  Each franchise has an `id` (string) and a list of players (maps).
  Each player map includes roster status (`"ROSTER"`|`"TAXI SQUAD"`
  |`"INJURED RESERVE"`) and possibly other data depending on league 
  settings, such as salary information in salary cap leagues.

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=rosters)
  """
  def rosters(year, league, options \\ []) do
    retrieve_league_node(["rosters", "franchise"], year, league, options)
  end

  @doc """
  Returns a list of player contract information.

  Note that salary values are returned as strings,
  and the associated numbers may/may not have decimal
  values.

  This appears somewhat arbitrary and not related to whether
  the league settings allow for sub-$1 salaries.

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=salaries)
  """
  def salaries(year, league, options \\ []) do
    retrieve_league_node(["salaries", "leagueUnit", "player"], year, league, options)
  end

  @doc """
  Returns a list of franchises and league standings.

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=leagueStandings)
  """
  def league_standings(year, league, options \\ []) do
    retrieve_league_node(["leagueStandings", "franchise"], year, league, options)
  end

  @doc """
  Returns a list of weekly matchup information.

  The returned data include score and winning/losing
  franchise in each matchup for each week. The results
  can be filtered by week and/or franchise via the `w:`
  and `f:` options.

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=schedule)
  """
  def schedule(year, league, options \\ []) do
    retrieve_league_node(["schedule", "weeklySchedule"], year, league, options)
  end

  @doc """
  Returns a list of weekly team/player scores.

  A week number (as a string) or `"YTD"` can provided
  to specify a week or weeks; otherwise results default
  to the current week. 

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=weeklyResults)
  """
  def weekly_results(year, league, options \\ []) do
    retrieve_league_node(["weeklyResults"], year, league, options)
  end

  @doc """
  Returns live scoring results for a given week. 

  Accepts week number option to specify a week or weeks; 
  otherwise results default to the current week. 

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=liveScoring)
  """
  def live_scoring(year, league, options \\ []) do
    retrieve_league_node(["liveScoring"], year, league, options)
  end

  @doc """
  Returns all player scores (including free agents) for a given week. 

  This request supports options for filtering by week, year,
  position, and specific player as well as other summary options.
  Note that per the documentation the league ID is optional, but
  calls without a league ID do not appear to produce meaningful data
  and are not supported.

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=playerScores)
  """
  def player_scores(year, league, options \\ []) do
    retrieve_league_node(["playerScores"], year, league, options)
  end

  @doc """
  Returns draft results for specified league

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=draftResults)
  """
  def draft_results(year, league, options \\ []) do
    retrieve_league_node(["draftResults", "draftUnit"], year, league, options)
  end

  @doc """
  Returns list of future draft picks by franchise.

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=futureDraftPicks)
  """
  def future_draft_picks(year, league, options \\ []) do
    retrieve_league_node(["futureDraftPicks", "franchise"], year, league, options)
  end

  @doc """
  Returns list of auction results

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=auctionResults)
  """
  def auction_results(year, league, options \\ []) do
    retrieve_league_node(["auctionResults", "auctionUnit", "auction"], year, league, options)
  end

  @doc """
  Returns a list of player `id`s for free agents.

  Just `id`s are returned; these must then be merged with data 
  from the other requests (e.g. `MFL.players/2` or elsewhere 
  to incorporate any related data such as the player's name or 
  team.

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=freeAgents)
  """
  def free_agents(year, league, options \\ []) do
    decoded = retrieve_league_node(["freeAgents", "leagueUnit", "player"], year, league, options)

    case decoded do
      {:error, message} ->
        %{error: message}

      records ->
        records
        |> Enum.map(&Map.take(&1, ["id"]))
        |> Enum.map(&Map.values(&1))
        |> List.flatten()
    end
  end

  @doc """
  Returns list of transactions.

  Supports several filters, e.g. week, franchise, transcation type 
  and number of days. 

  Note that the maps for different types of transactions have different
  keys. Add/drop-type transactions also appear to have a kind of pipe notation
  such that the `"transaction"` key for this kind of transaction may look like:

  ```
  "transaction" => "1234,|2|,6789" # $2 bid on player 1234, drop 6789
  "transaction" => "1234,|1|"      # $1 bid on player 1234, drop no one 
  "transaction" => "|6789"         # drop 6789
  ``` 

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=transactions)
  """
  def transactions(year, league, options \\ []) do
    retrieve_league_node(["transactions", "transaction"], year, league, options)
  end

  @doc """
  Returns list of projected scores for specified players.

  Note if only one players is returned, the return value is a map,
  not a list with one map element.

  Accepts week, position and free agent filters. Expects a player `id` 
  or comma-delimited list. If no player is provided, it appears to 
  return the projected score for an arbitrary player. If no week is 
  provided, returns results for the current week. If `count:` is 
  specified, returns that many arbitrary players.

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=projectedScores)
  """
  def projected_scores(year, league, options \\ []) do
    retrieve_league_node(["projectedScores"], year, league, options)
  end

  @doc """
  Returns list of message board topics (threads).

  Each topic has an `"id"` key that can be passed to `MFL.League.message_board_thread/4`
  as the `thread` argument.

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=messageBoard)
  """
  def message_board(year, league, options \\ []) do
    retrieve_league_node(["messageBoard", "thread"], year, league, options)
  end

  @doc """
  Returns list of messages for a given thread.

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=messageBoardThread)
  """
  def message_board_thread(year, league, thread, options \\ []) do
    options = Keyword.merge(options, thread: thread)
    retrieve_league_node(["messageBoardThread", "post"], year, league, options)
  end

  @doc """
  Returns players' "status".

  Note if only one player is returned, the return value is a map,
  not a list with one map element. If no week is specified, defaults
  to the current week.

  `"status"` appears to formatted as follows:

  ```
  "status" => "Joe's Team - S"                   # Started in specified week for Joe's Team
  "status" => "Joe's Team - NS"                  # Did not start in specified week for Joe's Team
  "status" => "Joe's Team - S<br  />Free Agent"  # Started in specified week for Joe's Team, now a free agent(?)
  "status" => "Free Agent"                       # Was a free agent
  ```

  There may be other statuses heretofore unobserved.

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=auctionResults)
  """
  # TODO: has to be a better way to implement conditional
  def player_status(year, league, player_list, options \\ []) do
    nodes =
      cond do
        length(player_list) > 1 ->
          ["playerStatuses", "playerStatus"]

        true ->
          ["playerStatus"]
      end

    player_list = Enum.join(player_list, "%2C")
    options = Keyword.merge(options, p: player_list)

    case fetch_league("playerStatus", year, league, options) do
      {:ok, response} ->
        decode_nodes(response.body, nodes)

      {:error, message} ->
        %{error: message}
    end
  end

  @doc """
  Returns list of NFL teams and points allowed by position. 

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=pointsAllowed)
  """
  def points_allowed(year, league, options \\ []) do
    retrieve_league_node(["pointsAllowed", "team"], year, league, options)
  end

  @doc """
  Returns list of NFL or fantasy pool picks.

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=pool)
  """
  def pool(year, league, options \\ []) do
    case fetch_league("pool", year, league, options) do
      {:ok, response} ->
        decode_nodes(response.body, ["poolPicks"])

      {:error, message} ->
        %{error: message}
    end
  end

  @doc """
  Returns a list of all playoff brackets for the league.

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=playoffBrackets)
  """
  def playoff_brackets(year, league, options \\ []) do
    retrieve_league_node(["playoffBrackets", "playoffBracket"], year, league, options)
  end

  @doc """
  Returns skins/tabs/home page modules set up by commissioner.

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=appearance)
  """
  def appearance(year, league, options \\ []) do
    retrieve_league_node(["appearance"], year, league, options)
  end

  defp flatten_rules(map) when is_map(map) do
    Map.put(map, "rule", flatten_rule_node(Map.get(map, "rule")))
  end

  defp flatten_rules(list) when is_list(list) do
    Enum.map(list, &flatten_rules/1)
  end

  defp flatten_rule_node(list) when is_list(list) do
    Enum.map(list, &flatten_nodes(&1, ["event", "points", "range"]))
  end

  defp flatten_rule_node(map) when is_map(map) do
    flatten_nodes(map, ["event", "points", "range"])
  end

  defp flatten_nodes(map, nodes) do
    Enum.reduce(nodes, map, &Map.put(&2, &1, &2[&1]["$t"]))
  end
end
