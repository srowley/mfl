defmodule MFL do
  @moduledoc """
  Selective Elixir wrapper for the MyFantasyLeague Developer API

  Strips out some of the response cruft that comes with MFL API
  calls. Not complete as I am initially focused only on the data
  needed to write a replacemnt auction app. 
  """

  @doc """
  Appends params to urls passed to HttPoison; overrides HttPoison.Base.process_url 
  """
  def request_url(type, year, param_list \\ []) do
    base_url = "http://www.myfantasyleague.com/#{year}/export?"
    param_list = param_list ++ [json: "1"]
    base_url <> url_params(param_list) <> "&TYPE=#{type}"
  end

  defp fetch(type, year, param_list \\ []) do
    url = request_url(type, year, param_list)
    HTTPoison.get(url, [], [follow_redirect: true])
  end

  defp url_params(params) do
    Enum.map_join(params,"&",(fn {k,v} -> Atom.to_string(k) <> "=" <> v end)) |> String.upcase
  end

  @doc """
  Takes string values for a league and year and returns a list of player IDs as strings.

  Reference API call: "http://www.myfantasyleague.com/2018/export&TYPE=freeAgents&L=66666&JSON=1
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
  Takes string values for year and returns a list of maps with player data.

  Reference API call: "http://www.myfantasyleague.com/2018/export&TYPE=players&JSON=1
  """
  def players(year) do
    {:ok, response} = fetch("players", year)
      response.body
        |> Poison.decode!
        |> Map.get("players")
        |> Map.get("player")
  end

  @doc """
  Takes string values for year and a league and returns a map of franchises.
  Each franchise has an id (string) and a map of players 
  (id, contract info and status ("ROSTER"|"TAXI SQUAD"|"INJURED RESERVE").

  Reference API call: "http://www.myfantasyleague.com/2018/export&TYPE=rosters&L=66666&JSON=1
  """

  def rosters(year, league) do
    {:ok, response} = fetch("rosters", year, [l: league])
      response.body
        |> Poison.decode!
        |> Map.get("rosters")
        |> Map.get("franchise")
  end

  @doc """
  Takes string values for year and returns a list of maps with salary adjustment data.

  Reference API call: "http://www.myfantasyleague.com/2018/export&TYPE=salaryAdjustements&L=66666&JSON=1
  """

  def salaryAdjustments(year, league) do
    {:ok, response} = fetch("salaryAdjustments", year, [l: league])
      response.body
        |> Poison.decode!
        |> Map.get("salaryAdjustments")
        |> Map.get("salaryAdjustment")
  end
end
