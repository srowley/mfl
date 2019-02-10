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
  Returns a list of player `id`s for free agents.

  Just `id`s are returned; these must then be merged with data 
  from the other requests (e.g. `MFL.players/2` or elsewhere 
  to incorporate any related data such as the player's name or 
  team.

  [MyFantastyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=freeAgents)
  """
  def free_agents(year, league, options \\ []) do
    options = Keyword.merge([l: league], options)

    case fetch("freeAgents", year, options) do
      {:ok, response} ->
        response.body
        |> Poison.decode!()
        |> Map.get("freeAgents")
        |> Map.get("leagueUnit")
        |> Map.get("player")
        |> Enum.map(&Map.take(&1, ["id"]))
        |> Enum.map(&Map.values(&1))
        |> List.flatten()

      {:error, message} ->
        %{error: message}
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
    options = Keyword.merge([l: league], options)

    case fetch("rosters", year, options) do
      {:ok, response} ->
        response.body
        |> Poison.decode!()
        |> Map.get("rosters")
        |> Map.get("franchise")

      {:error, message} ->
        %{error: message}
    end
  end

  @doc """
  Returns a list of maps with salary adjustment data.

  Note that the amount of the adjustment can be a decimal string, 
  e.g., `2.00`. Also note that the value applied to the cap is the 
  total of all adjustments. This can be confusing because the 
  MyFantasyLeague website page that displays adjustments for a team 
  only shows the most recent adjustments, so if there is a long history 
  the sum of the values displayed on the website does not equal 
  the amount actually applied.

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=salaryAdjustments)
  """
  def salary_adjustments(year, league) do
    case fetch("salaryAdjustments", year, l: league) do
      {:ok, response} ->
        response.body
        |> Poison.decode!()
        |> Map.get("salaryAdjustments")
        |> Map.get("salaryAdjustment")

      {:error, message} ->
        %{error: message}
    end
  end

  @doc """
  Returns league settings data for the specified league.

  Also includes some franchise information and links to previous years'
  home pages for that league.

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=league)
  """
  def league(year, league) do
    case fetch("league", year, l: league) do
      {:ok, response} ->
        response.body
        |> Poison.decode!()
        |> Map.get("league")

      {:error, message} ->
        %{error: message}
    end
  end
end
