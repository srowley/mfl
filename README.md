# MFL

MFL is a limited Elixir wrapper for the MyFantasyLeague (JSON) API.

This version only supports API requests that are required to support a 
simple live auction app (a potential replacement for the MyFantasyLeague version of that app). Over time I expect to support more requests; this
is not particulary hard to do for those interested in forking and augmenting.

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

Note that most requests take several optional arguments. MFL is designed to support those arguments but that support is not yet tested.

It should also be emphasized that all `id`s are strings, and, at least in the case of franchise `id`s, the values can have one or more leading zeroes. MFL returns all values as strings in order to avoid surprises - if a MyFantasyLeague request returns a value as a string, so does MFL.

## Next Steps

I am a fantasy football and software development enthusiast. I'm not paid to pursue either vocation, likely for good reason given my skill level in each area. I am most active in software development during the fantasy football offseason (for me, this is January-April or thereabouts). I have been interested in learning Elixir, and it happens to be well-suited for building a live auction app. MyFantasyLeague is unquestionably the best site available for serious fantasy football players, but its live auction capability is still not 100% reliable. 

This is all a long way of saying that the future for this library is certain to be uncertain. I will likely add an ADP request to support sorting free agents in my auction app by ADP. At that point my focus will likely shift a bit, although I find polishing this library to be a welcome distraction when I am stuck on something with that app. If there is anyone who actually ends up using this library, I would happily consider their requests as I prioritize what to add next.

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
