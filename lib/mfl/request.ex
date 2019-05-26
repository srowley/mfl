defmodule MFL.Request do
  @base_url Application.get_env(:mfl, :base_url)
  @api_url Application.get_env(:mfl, :api_url)
  @moduledoc false

  def fetch(type, year, options \\ []) do
    response =
      request_url(type, year, Keyword.delete(options, :token))
      |> HTTPoison.get([], [follow_redirect: true] ++ cookie(options))

    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: ""}} ->
        {:error, "MFL returned no data; check year and parameters"}

      {:ok,
       %HTTPoison.Response{status_code: 200, body: ~s<{"version":"1.0","error":> <> _rest = body}} ->
        {:error, Poison.decode!(body) |> Map.get("error") |> Map.get("$t")}

      {:ok, %HTTPoison.Response{status_code: 200}} ->
        response

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "MFL returned 'not found'; check year."}

      {:ok, %HTTPoison.Response{status_code: 500}} ->
        {:error, "MFL server error; check parameters."}

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "Error - HTTP status code #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTPoison error: #{reason}"}

      _ ->
        {:error, "Unknown error."}
    end
  end

  def fetch_league(type, year, league, options \\ []) do
    fetch(type, year, Keyword.merge(options, l: league))
  end

  def fetch_authenticated(type, year, league, [{:token, _token} | _others] = options) do
    fetch_league(type, year, league, options)
  end

  def retrieve_mfl_node([root | _children] = node_list, year, options \\ []) do
    with {:ok, response} <- fetch(root, year, options),
         {:ok, decoded} <- Poison.decode(response.body) do
      Enum.reduce(node_list, decoded, &Map.get(&2, &1))
    else
      error -> error
    end
  end

  def retrieve_league_node(node_list, year, league, options \\ []) do
    retrieve_mfl_node(node_list, year, Keyword.merge(options, l: league))
  end

  def retrieve_authenticated_node(node_list, year, league, [{:token, _token} | _others] = options) do
    retrieve_league_node(node_list, year, league, options)
  end

  def retrieve_authenticated_node(_node_list, _year, _league, _options) do
    {:error, "Must provide authentication token as first option."}
  end

  def decode_nodes(body, nodes) do
    case Poison.decode(body) do
      {:ok, decoded} ->
        Enum.reduce(nodes, decoded, &Map.get(&2, &1))

      {:error, error} ->
        {:error, error.message}

      _ ->
        {:error, "Unknown error."}
    end
  end

  def token(year, username, password) do
    base = "#{@api_url}/#{year}/login?"
    params = "USERNAME=#{username}&PASSWORD=#{password}&XML=1"

    headers =
      Map.get(HTTPoison.get!(base <> params), :headers)
      |> Map.new()

    case headers do
      %{"Set-Cookie" => value} ->
        token =
          value
          |> String.split("; ")
          |> List.first()
          |> String.split("=")
          |> List.last()

        {:ok, token}

      _ ->
        {:error, :not_authenticated}
    end
  end

  defp request_url(type, year, options) do
    @base_url
    |> Kernel.<>("/#{year}/export?")
    |> Kernel.<>("TYPE=#{type}")
    |> Kernel.<>(to_params(options))
    |> Kernel.<>("&JSON=1")
  end

  defp cookie(options) do
    if Keyword.has_key?(options, :token) do
      token =
        options
        |> hd()
        |> elem(1)

      [hackney: [cookie: ["MFL_USER_ID=#{token}"]]]
    else
      []
    end
  end

  # TODO: Be polite and sanitize params
  defp to_params([]), do: ""

  defp to_params(options) do
    ("&" <> Enum.map_join(options, "&", fn {k, v} -> Atom.to_string(k) <> "=" <> v end))
    |> String.upcase()
  end
end
