defmodule MFL.Request do
  @base_url Application.get_env(:mfl, :base_url) 
  @moduledoc false 

  # defguard token_in?(value) when length(value) > 1 and elem(hd(value),0) == :token

  def fetch(type, year, options \\ []) do #when token_in?(options) do
    cookie =
      if Keyword.has_key?(options, :token) do
        options
        |> hd() 
        |> elem(1)
        |> cookie_for()
      else
        []
      end

    IO.puts request_url(type, year, Keyword.delete(options, :token))
    request_url(type, year, Keyword.delete(options, :token))
    |> HTTPoison.get([], [follow_redirect: true] ++ cookie)
  end

  # def fetch(type, year, options \\ []) do
  #   request_url(type, year, options)
  #   |> HTTPoison.get([], [follow_redirect: true])
  # end

  # MFL documentation describing their API
  # authentication process is at:
  #
  # http://www.myfantasyleague/2019/api_info
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
