defmodule MFL.Request do
  @base_url Application.get_env(:mfl, :base_url) 
  @moduledoc false 

  def fetch(type, year, options \\ []) do
    cookie =
      if Keyword.has_key?(options, :token) do
        options
        |> hd() 
        |> elem(1)
        |> cookie_for()
      else
        []
      end

    response = 
      request_url(type, year, Keyword.delete(options, :token))
      |> HTTPoison.get([], [follow_redirect: true] ++ cookie)

    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: ""}} ->
        {:error, "MFL returned no data; check year and parameters"}
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

  def token(username, password) do
    base = "https://api.myfantasyleague.com/2018/login?"
    params = "USERNAME=#{username}&PASSWORD=#{password}&XML=1"
    response = HTTPoison.get!(base <> params)
  
    response.headers
    |> Map.new()
    |> Map.get("Set-Cookie")
    |> String.split("; ")
    |> List.first()
    |> String.split("=")
    |> List.last()
  end

  defp request_url(type, year, options \\ %{}) do
    @base_url
    |> Kernel.<>("/#{year}/export?")
    |> Kernel.<>("TYPE=#{type}")
    |> Kernel.<>(to_params(options))
    |> Kernel.<>("&JSON=1")
  end

  defp cookie_for(token) do
    [hackney: [cookie: ["MFL_USER_ID=#{token}"]]]
  end

  # TODO: Be polite and sanitize params
  defp to_params([]), do: ""
  defp to_params(options) do
    "&" <> Enum.map_join(options, "&", fn {k, v} -> Atom.to_string(k) <> "=" <> v end) |> String.upcase()
  end
end
