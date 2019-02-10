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
    player_list_request("players", year, options)
  end

  @doc """
  Returns a list of player `id`s and draft position information.

  ADP information includes how many drafts the player was selected 
  in, the average pick, minimum pick and maximum pick.

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=adp)
  """

  def adp(year, options \\ []) do
    player_list_request("adp", year, options)
  end

  @doc """
  Returns a list of player `id`s and auction value information.

  AAV information includes how many auctions the player was selected 
  in and the average auction value. This value is normalized under the
  assumption that $1,000 is available to all franchises in the auction.

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=aav)
  """

  def aav(year, options \\ []) do
    player_list_request("aav", year, options)
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
    player_list_request("topAdds", year, options)
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
    player_list_request("topDrops", year, options)
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
    player_list_request("topOwns", year, options)
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
    player_list_request("topStarters", year, options)
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
        response.body
        |> Poison.decode!()
        |> Map.get("league")

      {:error, message} ->
        %{error: message}
    end
  end

  defp player_list_request(type, year, options) do
    case fetch(type, year, options) do
      {:ok, response} ->
        response.body
        |> Poison.decode!()
        |> Map.get(type)
        |> Map.get("player")

      {:error, message} ->
        %{error: message}
    end
  end
end
