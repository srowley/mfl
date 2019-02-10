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
    case fetch("players", year, options) do
      {:ok, response} ->
        response.body
        |> Poison.decode!()
        |> Map.get("players")
        |> Map.get("player")

      {:error, message} ->
        %{error: message}
    end
  end

  @doc """
  Returns league descriptive and configuration data. This 
  request has no optional parameters.

  If passed an authentication token, additional details
  for the authenticated user are included in the results.
  This is currently only used internally to support 
  `franchise_for_user\4`.

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=league)
  """
  def league(year, league, token) do
    case fetch("league", year, token: token, l: league) do
      {:ok, response} ->
        response.body
        |> Poison.decode!()
        |> Map.get("league")

      {:error, message} ->
        %{error: message}
    end
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
end
