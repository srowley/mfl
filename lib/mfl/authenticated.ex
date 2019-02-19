defmodule MFL.Authenticated do
  @moduledoc """
  Wrapper for requests which return information for a specific
  league that is always restricted to authenticated users.

  The structure for every call is `MFL.Authenticated.request_type(year, id, options)`
  where the `id` is a league `id` and the MyFantasyLeague request 
  name is "requestType". The `options` parameter is a keyword list;
  it is not optional for calls to these functions, and the first tuple
  in the list must be `token: "TOKEN"` where `"TOKEN"` is the value returned
  by `MFL.Request.token/2` given a valid username and password.

  See the `MFL` module documentation for a discussion of optional 
  request/function parameters.
  """

  import MFL.Request

  # @doc """

  # [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=pendingWaivers)
  # """
  # def pending_waivers(year, league, options) do
  # end

  @doc """
  Returns a list of of league accounting records.

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=accounting)
  """
  def accounting(year, league, options) do
    retrieve_authenticated_node(["accounting", "entry"], year, league, options)
  end

  @doc """
  Returns a list of league calendar events.

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=calendar)
  """
  def calendar(year, league, options) do
    retrieve_authenticated_node(["calendar", "event"], year, league, options)
  end

  # @doc """

  # [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=pendingTrades)
  # """
  # def pending_trades(year, league, options \\ []) do
  # end

  @doc """
  Returns a list of lists of tradeable assets.

  Depending on league rules, assets may include a list
  of players, list of draft picks and/or blind bidding
  dollars.

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=assets)
  """
  def assets(year, league, options \\ []) do
    retrieve_authenticated_node(["assets", "franchise"], year, league, options)
  end

  @doc """
  Returns a list of player `id`s on the watch list of the
  authenticated user for the specified league.

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=myWatchList)
  """
  def my_watch_list(year, league, options) do
    retrieve_authenticated_node(["myWatchList", "player"], year, league, options)
    |> Enum.map(&(Map.get(&1,"id")))
  end

  @doc """
  UNTESTED - Returns a list of player `id`s on the draft list of the
  authenticated user for the specified league.

  Assumed to be implemented similar to `MFL.Authenticated.my_watch_list/3`.
  This function has not been tested as there are no available sample
  documents as of this package version.

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=myDraftList)
  """
  def my_draft_list(year, league, options) do
    retrieve_authenticated_node(["myDraftList", "player"], year, league, options)
    |> Enum.map(&(Map.get(&1,"id")))
  end

  @doc """
  Returns a list of league polls and associated details.

  [MyFantasyLeague documentation](https://www03.myfantasyleague.com/2018/api_info?STATE=test&CMD=export&TYPE=polls)
  """
  def polls(year, league, options) do
    retrieve_authenticated_node(["polls", "poll"], year, league, options)
  end
end
