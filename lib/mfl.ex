defmodule MFL do
  @moduledoc """
  Selective Elixir wrapper for the MyFantasyLeague Developer (JSON) API.

  This version only supports endpoints that are required
  to support a simple replacement auction app. All values
  are returned as strings. Notably MFL "id's for some entities
  (.e.g. franchises and players) are strings of digits
  which often include leading zeroes.

  MFL data structures also seem somewhat arbitrary
  with respect to whether children of a node are
  modeled as attributes or nodes.
  """

  import MFL.Request

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

  Options

  details: (1) includes additional data, e.g. id's at other sites
  since: (Unix timestamp) limit to changes since this time
  players: (comma-separated list of id's) filter by player(s)

  Reference API call:
  http://www.myfantasyleague.com/[YEAR HERE]/export&TYPE=players&JSON=1
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
  Returns the league data for an authenticated user.

  Accepts a user name and password, and if the user
  is authenticated, passes a user cookie with the 
  request, which then returns additional information,
  in particular the franchise id for that user's
  franchise.
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
  Returns the franchise id associated with an 
  authenticated user.
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
