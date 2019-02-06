defmodule MFL do
  @moduledoc """
  Selective Elixir wrapper for the MyFantasyLeague Developer (JSON) API.

  This version only supports endpoints that are required
  to support a simple replacement auction app. All values
  are returned as strings. Notably MFL "id"s for some entities
  (.e.g. franchises and players) are strings of digits
  which often include leading zeroes.

  MFL data structures also seem somewhat arbitrary
  with respect to whether children of a node are
  modeled as attributes or nodes.
  """

  @doc """
  Returns a list of player id's for free agents.
  
  Just id's are returned; the id's must then
  be merged with data from the  players endpoint 
  or elsewhere to incorpoate any  related date, 
  such as the player's name or team.

  Sample document:
  http://www59.myfantasyleague.com/2015/export&TYPE=freeAgents&L=35465&JSON=1
  """
  def freeAgents(year, league) do
    {:ok, response} = fetch("freeAgents", year, [l: league])
      response.body
        |> Poison.decode!
        |> Map.get("freeAgents")
        |> Map.get("leagueUnit")
        |> Map.get("player")
        |> Enum.map(&(Map.take(&1,["id"])))
        |> Enum.map(&(Map.values(&1)))
        |> List.flatten
  end

  @doc """
  Returns the entire list of players in the MFL database
  with basic details.
  
  The MFL API also supports limiting the query to a 
  specified player or list of players, or to changes
  since a specified time. It also provides an option
  to retrieve an expanded set of details. These
  options are not supported at this time.

  MFL strongly recommends caching the results of this call
  given the size of the returned dataset (~2000 rows), and
  the fact that is only typically updated no more
  frequently than once per day.

  Reference API call:
  http://www.myfantasyleague.com/[YEAR HERE]/export&TYPE=players&JSON=1
  """
  def players(year) do
    {:ok, response} = fetch("players", year)
      response.body
        |> Poison.decode!
        |> Map.get("players")
        |> Map.get("player")
  end

  @doc """
  Returns a map of rosters for each franchise.

  Each franchise has an id (string) and a map of players 
  (id, contract info and status ("ROSTER"|"TAXI SQUAD"|"INJURED RESERVE").

  Sample document:
  http://www59.myfantasyleague.com/2015/export&TYPE=rosters&L=35465&JSON=1
  """
  def rosters(year, league) do
    {:ok, response} = fetch("rosters", year, [l: league])
      response.body
        |> Poison.decode!
        |> Map.get("rosters")
        |> Map.get("franchise")
  end

  @doc """
  Returns a list of maps with salary adjustment data.

  Note that the amount of the adjustment is a decimal
  string, e.g. "2.00". Also note that the value applied
  to the cap is the total of all adjustments. This can 
  be confusing because the MFL site page that displays 
  adjustments for a team only show as subset, so if 
  there is a long history of adjustments, the sum of 
  the values displayed does not equal the amount applied.

  Reference API call:
  http://www.myfantasyleague.com/2018/export&TYPE=salaryAdjustments&L=66666&JSON=1
  """
  def salaryAdjustments(year, league) do
    {:ok, response} = fetch("salaryAdjustments", year, [l: league])
      response.body
        |> Poison.decode!
        |> Map.get("salaryAdjustments")
        |> Map.get("salaryAdjustment")
  end

  @doc """
  Returns various league settings data.
  
  Also includes some franchise information and 
  links to previous years' home pages.

  Sample document:
  http://www59.myfantasyleague.com/2015/export&TYPE=league&L=35465&JSON=1
  """
  def league(year, league) do
    {:ok, response} = fetch("league", year, [l: league])
      response.body
        |> Poison.decode!
        |> Map.get("league")
  end


  @doc """
  Returns the league data for an authenticated user.
  
  Accepts a user name and password, and if the user
  is authenticated, passes a user cookie with the 
  request, which then returns additional information,
  in particular the franchise id for that user's
  franchise.
  """
  def league(year, league, username, password) do
    auth_token = token(username, password)
    {:ok, response} = fetch("league", year, [l: league], auth_token)
      response.body
        |> Poison.decode!
        |> Map.get("league")
  end

  @doc """
  Returns the franchise id associated with an 
  authenticated user.
  """
  def franchise_for_user(year, league, username, password) do
    league(year, league, username, password)
    |> Map.get("franchises")
    |> Map.get("franchise")
    |> Enum.filter(&(&1["username"] == username))
    |> List.first
    |> Map.get("id")
  end

  defp request_url(type, year, param_list \\ []) do
    base_url = "http://www.myfantasyleague.com/#{year}/export?"
    param_list = param_list ++ [json: "1"]
    base_url <> url_params(param_list) <> "&TYPE=#{type}"
  end

  # MFL documentation describing their API
  # authentication process is at:
  #
  # http://www.myfantasyleague/2019/api_info
  defp token(username, password) do
    base  = "https://api.myfantasyleague.com/2018/login?"
    params = "USERNAME=#{username}&PASSWORD=#{password}&XML=1"
    response = HTTPoison.get!(base <> params)
    response.headers
    |> Map.new
    |> Map.get("Set-Cookie")
    |> String.split("; ")
    |> List.first()
    |> String.split("=")
    |> List.last()
  end

  # Note that calls to wwww.myfantasyleague.com
  # are redirected to www##.myfantasyleague.com,
  # hence the "follow_redirect: true" option 
  # being passed as an option to HTTPoison.get/3.
  defp fetch(type, year, param_list \\ [], auth_token \\ "") do
    url = request_url(type, year, param_list)
    options = [follow_redirect: true] ++ cookie(auth_token)
    HTTPoison.get(url, [], options)
  end

  defp url_params(params) do
    Enum.map_join(params,"&",(fn {k,v} -> Atom.to_string(k) <> "=" <> v end)) |> String.upcase
  end

  defp cookie(""), do: []

  defp cookie(auth_token) do
    [hackney: [cookie: ["MFL_USER_ID=#{auth_token}"]]]
  end
end
