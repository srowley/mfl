# MFL

MFL is a limited Elixir wrapper for the MyFantasyLeague (JSON) API.

This version will support almost all API export requests. Import requests are likely to be added eventually; testing them acceptably will be challenging.

## Installation

Until the package becomes available in Hex, it can be installed
by adding `mfl` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:mfl, git: "git://github.com/srowley/mfl.git"}
  ]
end
```

You will also need to add the following line to `config.exs`:

```elixir
config :mfl, :base_url, "https://www.myfantasyleague.com"
```

Finally, because all calls to the MFL API specify a year, it may be useful to define the current league year in your application configuration as well. This supports the definition of module attributes that reference the current year. For example, in `config.exs`, you could enter:

```elixir
config :my_app, :league_year, "2018"
```

and then in the module calling the API:

```elixir
defmodule MyApp.GetsMFLData do
  @league_year Application.get_env(:my_app, :league_year)

...
```

Note that the MFL package does not require this, so the example above is illustrative and these steps are optional.

## Usage

The MyFantasyLeague API is [documented on the MyFantasyLeague website](https://www.myfantasyleague.com/2018/api_info). The [request reference page](https://www.myfantasyleague.com/2018/api_info?STATE=details) is particularly helpful.

Note that most requests take several optional arguments. MFL is designed to support those arguments but that support is not fully tested.

It should also be emphasized that all `id`s are strings, and, at least in the case of franchise `id`s, the values can have one or more leading zeroes. MFL returns all values as strings in order to avoid surprises - if a MyFantasyLeague request returns a value as a string, so does MFL.
<!---
If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `mfl` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:mfl, "~> 0.1.0"}
  ]
end
```
-->
