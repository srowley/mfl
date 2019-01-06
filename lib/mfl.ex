defmodule MFL do
  @moduledoc """
  Selective Elixir wrapper for the MyFantasyLeague Developer API

  Strips out some of the response cruft that comes with MFL API
  calls. Not complete as I am initially focused only on the data
  needed to write a replacemnt auction app. 
  """

  @doc """
  Takes string values for a league and year and 
  returns a list of player IDs as strings.

  Reference API call:
  http://www.myfantasyleague.com/2018/export&TYPE=freeAgents&L=66666&JSON=1
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
  Takes string values for year and returns a
  list of maps with player data.

  Reference API call:
  http://www.myfantasyleague.com/2018/export&TYPE=players&JSON=1
  """
  def players(year) do
    {:ok, response} = fetch("players", year)
      response.body
        |> Poison.decode!
        |> Map.get("players")
        |> Map.get("player")
  end

  @doc """
  Takes string values for year and a league and
  returns a map of franchises.

  Each franchise has an id (string) and a map of players 
  (id, contract info and status ("ROSTER"|"TAXI SQUAD"|"INJURED RESERVE").

  Reference API call:
  http://www.myfantasyleague.com/2018/export&TYPE=rosters&L=66666&JSON=1
  """

  def rosters(year, league) do
    {:ok, response} = fetch("rosters", year, [l: league])
      response.body
        |> Poison.decode!
        |> Map.get("rosters")
        |> Map.get("franchise")
  end

  @doc """
  Takes string values for year and returns a list of
  maps with salary adjustment data.

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
  Takes string values for year and league ID and returns
  various data about the league.

  Reference API call:
  http://www.myfantasyleague.com/2018/export&TYPE=league&L=66666&JSON=1
  """

  def league(year, league) do
    {:ok, response} = fetch("league", year, [l: league])
      response.body
        |> Poison.decode!
        |> Map.get("league")
  end

  @doc """
  Gets franchise name for the authenticated user.
  Same API call but passes token as a cookie.
  """

  def league(year, league, username, password) do
    auth_token = token(username, password)
    {:ok, response} = fetch("league", year, [l: league], auth_token)
      response.body
        |> Poison.decode!
        |> Map.get("league")
  end

  @doc """
  Gets franchise associated with authenticated user
  in a given leage/year. 
  """
  def franchise_for_user(year, league, username, password) do
    league(year, league, username, password)
    |> Map.get("franchises")
    |> Map.get("franchise")
    |> Enum.filter(&(&1["username"] == username))
    |> List.first
    |> Map.get("id")
  end

  # Appends params to urls passed to HTTPoison;
  # overrides HttPoison.Base.process_url 
  defp request_url(type, year, param_list \\ []) do
    base_url = "http://www.myfantasyleague.com/#{year}/export?"
    param_list = param_list ++ [json: "1"]
    base_url <> url_params(param_list) <> "&TYPE=#{type}"
  end

  # Retrieves token for given set of credentials.
  # Reference at:
  # http://www.myfantasyleague.com/2018/api_info 
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

  # Execute HTTP request to MFL API and return response.

  # Note that calls to wwww.myfantasyleague.com
  # are redirected to www##.myfantasyleague.com
  # where is the URL for the real host, hence
  # the "follow_redirect: true" option passed
  # to HTTPoison.get.
  defp fetch(type, year, param_list \\ [], auth_token \\ "") do
    url = request_url(type, year, param_list)
    options = [follow_redirect: true] ++ cookie_option(auth_token)
    HTTPoison.get(url, [], options)
  end

  # Parse map and return standard request
  # params string.
  defp url_params(params) do
    Enum.map_join(params,"&",(fn {k,v} -> Atom.to_string(k) <> "=" <> v end)) |> String.upcase
  end

  # Matches default value when no token is
  # passed to an API call.  
  defp cookie_option(auth_token = "") do
    []
  end

  # Formats token in keyword list formatted 
  # for consumption by HTTPoison.get/1
  defp cookie_option(auth_token) do
    [hackney: [cookie: ["MFL_USER_ID=#{auth_token}"]]]
  end

end
