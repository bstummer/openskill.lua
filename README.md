# openskill.lua

openskill.lua is an implementation of the [Weng-Lin Bayesian ranking](https://www.csie.ntu.edu.tw/~cjlin/papers/online_ranking/online_journal.pdf), a better, license-free alternative to the [TrueSkill](https://www.microsoft.com/en-us/research/project/trueskill-ranking-system) ranking system.

It is a Luau port of the amazing [openskill.js](https://github.com/philihp/openskill.js) module, designed specifically for Roblox game development.

## Installation

Get the module [here](https://www.roblox.com/library/8134663273) and insert it into your game (preferably in ServerStorage).

Alternatively, you can paste this directly into your Roblox Studio command bar:

```lua
game:GetObjects("rbxassetid://8134663273")[1].Parent=game.ServerStorage
```

## Quick Start

### 1. Require the Module

Create a script and require the module:

```lua
local OpenSkill = require(game.ServerStorage.OpenSkill)
```

### 2. Create Ratings

You can create a rating for every player to describe their skill. Ratings are represented as a Gaussian curve with two properties:

- mu: The average skill of the player.
- sigma: The degree of uncertainty in the player's skill.

Maintaining an uncertainty (sigma) allows the system to make large changes to skill estimates early on, but smaller, more stable changes after a series of consistent games.

```lua
local a1 = OpenSkill.Rating() --> {mu = 25, sigma = 8.333}
local a2 = OpenSkill.Rating(32.444) --> {mu = 32.444, sigma = 10.814}
local b1 = OpenSkill.Rating(nil, 2.421) --> {mu = 25, sigma = 2.421}
local b2 = OpenSkill.Rating(25.188, 6.211) --> {mu = 25.188, sigma = 6.211}
```

### 3. Rate a Match

If `a1` and `a2` form a team and win against a team of `b1` and `b2`, you can update their skill ratings:

```lua
OpenSkill.Rate({{a1, a2}, {b1, b2}})
```

### 4. Displaying Ratings

When displaying a rating or sorting a leaderboard, use `Ordinal`. By default, this returns `mu - 3 * sigma`, showing a rating for which there is a 99.7% likelihood the player's true rating is higher. In early games, a player's ordinal rating will usually go up, even if they lose!
```lua
OpenSkill.Ordinal(a1) --> 0 (before rating)
OpenSkill.Ordinal(a1) --> 2.3245624871094 (after winning)
```

## Advanced Match Results

### Custom Ranks

If your teams are listed in one order but your ranking is in a different order, you can specify a `rank` option. Lower ranks are considered better.

```lua
local a = OpenSkill.Rating()
local b = OpenSkill.Rating()
local c = OpenSkill.Rating()
local d = OpenSkill.Rating()

OpenSkill.Rate({{a}, {b}, {c}, {d}}, { --4 teams consisting of 1 player
	rank = {4, 1, 3, 2}
})
```
*In this example, team b placed 1st, d placed 2nd, c placed 3rd, and a placed 4th.*

### Custom Scores

You can also provide a score instead, where higher is better. These can just be raw scores from the game.

```lua
OpenSkill.Rate({{a}, {b}, {c}, {d}}, {
	score = {37, 19, 37, 42}
})
```
*Note: Ties should have either an equivalent rank or score.*

## Rating Models

openskill.lua provides two rating models: `PlackettLuce` and `ThurstoneMosteller`.
- Plackett-Luce (Default): A generalized Bradley-Terry model for k ≥ 3 teams which scales best. It follows a logistic distribution over a player's skill, similar to Glicko.
- Thurstone-Mosteller: Follows a Gaussian distribution, similar to TrueSkill. Accuracy is usually slightly lower than Plackett-Luce, but can be tuned with an alternative gamma function.

*Note: openskill.lua uses full pairing which yields highly accurate ratings. However, in games with an extremely high number of teams (100+), calculations become computationally expensive due to joint probability integration.*

You can change the global default model or pass it per-match:

```lua
-- Global
OpenSkill.Settings.DefaultModel = "ThurstoneMosteller"

-- Per-match
OpenSkill.Rate({{a}, {b}, {c}, {d}}, {
	model = "ThurstoneMosteller"
})
```


## API Reference

```lua
OpenSkill.DefaultModel : string
```
Determines the model which is used by default.

```lua
OpenSkill.Rating(mu : number?, sigma : number?, options : any?): rating
```
Creates a rating object, which describes a player's skill. Ratings are kept as an object which represent a gaussian curve, with properties where `mu` represents the mean, and `sigma` represents the spread or standard deviation. `mu` is the average skill of the player and `sigma` is the degree of uncertainty in the player's skill. Maintaining an uncertainty allows the system to make big changes to the skill estimates early on but small changes after a series of consistent games has been played. If omitted, `mu` defaults to 25 and `sigma` defaults to 25 / 3.


```lua
OpenSkill.Ordinal(rating : rating, options : any?): number
```
Represents a player's skill estimate as a single number. By default, this returns `mu - 3 * sigma`, showing a rating for which there's a [99.7%](https://en.wikipedia.org/wiki/68–95–99.7_rule) likelihood the player's true rating is higher. So in early games, a player's ordinal rating will usually go up and could go up even if that player loses.


```lua
OpenSkill.Rate(teams : {{rating}}, options : any?): {{{number}}}
```
Takes an array of teams (which are arrays of ratings) and updates their values based on the outcome of the match. Returns the new rating values in identically structured arrays.


```lua
OpenSkill.WinProbability(teams : {{rating}}, options : any?): {number}
```
Calculates the probability of each team winning the match.


```lua
OpenSkill.DrawProbability(teams : {{rating}}, options : any?): number
```
Calculates the probability of a draw between the teams. This is extremely useful for determining fair team compositions in matchmaking.

## Contributing

Contributions, issues, and feature requests are greatly appreciated!
