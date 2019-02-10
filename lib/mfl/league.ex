defmodule MFL.League do
  @moduledoc """
  Elixir wrapper for MFL API functions which
  return information for a given league.

  This module contains functions that make API
  calls that require a league id as an argument 
  (and therefore return information just for a
  given league).

  The structure for every call is
  "end_point(year, id, options)" where the id
  is a league id and the MFL endpoint name is
  "endPoint".

  Because the year is in all likelihood going 
  to be a configured value applicable across 
  all leagues, it can be convenient to set its
  value once as a module attribute for use in
  these functions.
  """

  import MFL.Request

  @doc """
  Returns a list of player id's for free agents.

  Just id's are returned; the id's must then
  be merged with data from the  players endpoint 
  or elsewhere to incorpoate any  related date, 
  such as the player's name or team.

  Options:

  position: ("QB", "RB", etc.)
  filters list by position

  Sample document:
  http://www59.myfantasyleague.com/2015/export&TYPE=freeAgents&L=35465&JSON=1
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
  Returns a map of rosters for each league franchise.

  Each franchise has an id (string) and a list of players.
  Each player item includes roster status
  ("ROSTER"|"TAXI SQUAD"|"INJURED RESERVE") and possibly
  other date depending on league settings, such as salary
  information in salary cap leagues.

  Options:

  franchise: franchise_id 
  returns roster for specified franchise only 

  Sample document:
  http://www59.myfantasyleague.com/2015/export&TYPE=rosters&L=35465&JSON=1
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

  Note that the amount of the adjustment is a decimal
  string, e.g., "2.00". Also note that the value applied
  to the cap is the total of all adjustments. This can 
  be confusing because the MFL site page that displays 
  adjustments for a team only show as subset, so if 
  there is a long history of adjustments, the sum of 
  the values displayed does not equal the amount applied.

  Reference API call:
  http://www.myfantasyleague.com/2018/export&TYPE=salaryAdjustments&L=66666&JSON=1
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
  Returns various league settings data.

  Also includes some franchise information and 
  links to previous years' home pages.

  Sample document:
  http://www59.myfantasyleague.com/2015/export&TYPE=league&L=35465&JSON=1
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
