defmodule MFL do
  @moduledoc """
  This module includes wrappers for requests that are not
  tied to a specific league.

  Most requests supported by MFL are intended to retrieve
  data from a given league. These functions are housed in `MFL.League`.

  Functions that correspond directly to a MyFantasyLeague
  request are structured as follows:

  |                 |MyFantasyLeague         |MFL               |
  |-----------------|------------------------|------------------|
  |Request/function |players                 |`MFL.players/2`   |
  |Parameters       |DETAILS, SINCE, PLAYERS |`year`, `options` |

  `year` is a string corresponding to the league year.
 
  `options` is a keyword list corresponding to the optional
  (downcased) request parameters, e.g. `[details: "1"]`. MFL is 
  designed to support optional parameters but this support is not 
  tested. Optional parameters are documented on the
  [MyFantasyLeague Request Reference page](https://www03.myfantasyleague.com/2018/api_info?STATE=details).

  `MFL` also provides a convenience function - `MFL.franchise_for_user/4`
  to return the franchise `id` for a given user's team in a given 
  league.
  """

  import MFL.Request


  @doc """
  Returns a list of all MFL rule/scoring setting codes 
  and their descriptions.

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=allRules)
  """
  def all_rules(year, options \\ []) do
    case fetch("allRules", year, options) do
      {:ok, response} ->
        decode_nodes(response.body, ["allRules", "rule"])
        |> flatten_maps(["abbreviation", "shortDescription", "detailedDescription"])

      {:error, message} ->
        %{error: message}
    end
  end


  @doc """
  Returns a list of `id`s for players that are on the
  injury report for a given week.
  
  The week can be specified as an option, (i.e., `w: "2"`);
  if no week is provided the request defaults to the most 
  recent week available. 

  The returned map includes a Unix timestamp indicating when
  the data was last updated and the applicable week.

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=injuries)
  """
  def injuries(year, options \\ []) do
    retrieve_mfl_node(["injuries"], year, options)
  end

  @doc """
  Returns a list of maps with information about each NFL
  game for the specified week.
  
  The week can be specified as an option, (i.e., `w: "2"`);
  if no week is provided the request defaults to the most 
  recent week available. 

  This data includes pre-game information (point spread,
  offense/defense rank) and in-game information (score,
  team with possession, etc.) The MyFantasyLeague documentation
  notes that this information is only updated every two minutes
  and that more frequent calls are considered abuse of its
  system. 

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=nflSchedule)
  """
  def nfl_schedule(year, options \\ []) do
    retrieve_mfl_node(["nflSchedule"], year, options)
  end

  @doc """
  Returns a list of NFL teams and their bye week for the
  specified year.

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=nflByeWeeks)
  """
  def nfl_bye_weeks(year, options \\ []) do
    retrieve_mfl_node(["nflByeWeeks", "team"], year, options)
  end

  @doc """
  Returns a list of leagues with names that contain the
  search string.

  The search is case-insensitive.

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=leagueSearch)
  """
  def league_search(year, search)do
    case fetch("leagueSearch", year, search: search) do
      {:ok, response} ->
        decode_nodes(response.body, ["leagues", "league"])

      {:error, message} ->
        %{error: message}
    end
  end

  @doc """
  Returns personal data for the given player, e.g.,
  height, weight, date of birth.

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=playerProfile)
  """
  def player_profile(year, player_id) do
    retrieve_mfl_node(["playerProfile"], year, p: player_id)
  end

  @doc """
  Returns a list of pairs of players, `"shouldStart"` and
  `"shouldBench"`. 
  
  Also returns the percentage of the time `"shouldStart"` was 
  preferred and how many teams made lineup decision between 
  the two. Can be passed an applicable week (if not provided
  defaults to most recent week).

  Results can be limited to players owned by a certain franchise
  by passing a franchise, i.e. `f: "0001"`.

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=whoShouldIStart)
  """
  def who_should_i_start(year, options \\ []) do
    retrieve_mfl_node(["whoShouldIStart"], year, options)
  end

  @doc """
  Returns the entire list of players in the MFL database
  with basic details.

  MyFantasyLeague optionally supports limiting the query to 
  a specified player or list of players, or to changes
  since a specified time. It also provides an option
  to retrieve an expanded set of details. These
  options should work with MFL but have not been tested.

  MyFantasyLeague strongly recommends caching the results of
  this call given the size of the returned dataset (~2000 rows)
  and the fact that the data is typically updated no more
  frequently than once per day.
  
  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=players)
  """

  def players(year, options \\ []) do
    retrieve_mfl_node(["players", "player"], year, options)
  end

  @doc """
  Returns a list of player `id`s and draft position information.

  ADP information includes how many drafts the player was selected 
  in, the average pick, minimum pick and maximum pick.

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=adp)
  """

  def adp(year, options \\ []) do
    retrieve_mfl_node(["adp", "player"], year, options)
  end

  @doc """
  Returns a list of player `id`s and auction value information.

  AAV information includes how many auctions the player was selected 
  in and the average auction value. This value is normalized under the
  assumption that $1,000 is available to all franchises in the auction.

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=aav)
  """

  def aav(year, options \\ []) do
    retrieve_mfl_node(["aav", "player"], year, options)
  end

  @doc """
  Returns a list of player `id`s for the most-added players in
  MyFantasyLeague leagues.
 
  The results are based on transactions  for a given week (specified 
  in the options, e.g., `w: "2"`. If no week is specified, data for 
  the most recent available week is returned. Each record also includes
  the percentage of leagues in which the player was added that week.
  the most recent available week is returned.

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=topAdds)
  """

  def top_adds(year, options \\ []) do
    retrieve_mfl_node(["topAdds", "player"], year, options)
  end

  @doc """
  Returns a list of player `id`s for the most-dropped players in
  MyFantasyLeague leagues.
 
  The results are based on transactions  for a given week (specified 
  in the options, e.g., `w: "2"`. If no week is specified, data for 
  the most recent available week is returned. Each record also includes
  the percentage of leagues in which the player was dropped that week.

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=topDrops)
  """

  def top_drops(year, options \\ []) do
    retrieve_mfl_node(["topDrops", "player"], year, options)
  end

  @doc """
  Returns a list of player `id`s for the most-owned players in
  MyFantasyLeague leagues.
 
  The results are based on transactions  for a given week (specified 
  in the options, e.g., `w: "2"`. If no week is specified, data for 
  the most recent available week is returned. Each record also includes
  the percentage of leagues in which the player was owned that week.
  the most recent available week is returned.
 
  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=topOwns)
  """

  def top_owns(year, options \\ []) do
    retrieve_mfl_node(["topOwns", "player"], year, options)
  end

  @doc """
  Returns a list of player `id`s for the most-started players in
  MyFantasyLeague leagues.
 
  The results are based on transactions  for a given week (specified 
  in the options, e.g., `w: "2"`. If no week is specified, data for 
  the most recent available week is returned. Each record also includes
  the percentage of leagues in which the player was started that week.
  the most recent available week is returned.

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=topStarters)
  """

  def top_starters(year, options \\ []) do
    retrieve_mfl_node(["topStarters", "player"], year, options)
  end

  @doc """
  Returns the franchise `id` for the team owned by the specified
  user in the specified league.

  Not a direct call to an MFL request - this function returns 
  the franchise `id` associated with a given user. This is
  only available if the user has been authenticated. Thus the
  function requires a valid username and password for that user. 

  Note that MyFantasyLeague franchise `id`s are strings
  and contain leading zeroes.  
  """
  def franchise_for_user(year, league, username, password) do
    league(year, league, token(username, password))
    |> Map.get("franchises")
    |> Map.get("franchise")
    |> Enum.filter(&(&1["username"] == username))
    |> List.first()
    |> Map.get("id")
  end

  # This is currently only used internally to support 
  # `franchise_for_user\4`.
  defp league(year, league, token) do
    case fetch("league", year, token: token, l: league) do
      {:ok, response} ->
        decode_nodes(response.body, ["league"])

      {:error, message} ->
        %{error: message}
    end
  end

  defp flatten_maps(map_list, nodes) do
    Enum.map(map_list, &(flatten_nodes(&1, nodes)))
  end

  defp flatten_nodes(map, nodes) do
    Enum.reduce(nodes, map, &(Map.put(&2, &1, &2[&1]["$t"])))
  end
end
