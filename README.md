openskill.lua is an implementation of the [Weng-Lin Bayesian ranking](https://www.csie.ntu.edu.tw/~cjlin/papers/online_ranking/online_journal.pdf), a better, license-free alternative to [TrueSkill](https://www.microsoft.com/en-us/research/project/trueskill-ranking-system).

It is a port of the amazing [openskill.js](https://github.com/philihp/openskill.js) module.

---

Firstly, get the module [here](https://www.roblox.com/library/8134663273) and insert it into your game (preferably ServerStorage). You can also just paste this in the command bar:
```lua
game:GetObjects("rbxassetid://8134663273")[1].Parent=game.ServerStorage
```

<br>

Create a script and require the module:
```lua
local OpenSkill = require(game.ServerStorage.OpenSkill)
```

<br>

You can create a rating for every player, which describes their skill. Ratings are kept as an object which represent a gaussian curve, with properties where `mu` represents the mean, and `sigma` represents the spread or standard deviation. Create these with:
```lua
local a1 = OpenSkill.Rating() --> {mu = 25, sigma = 8.333333333333334}
local a2 = OpenSkill.Rating(32.444) --> {mu = 32.444, sigma = 10.81466666666667}
local b1 = OpenSkill.Rating(nil, 2.421) --> {mu = 25, sigma = 2.421}
local b2 = OpenSkill.Rating(25.188, 6.211) --> {mu = 25.188, sigma = 6.211}
```

<br>

If `a1` and `a2` are on a team and win against a team of `b1` and `b2`, you can update their skill ratings like this:
```lua
OpenSkill.Rate({{a1, a2}, {b1, b2}})
```

<br>

When displaying a rating or sorting a list of ratings, you can use `Ordinal`:
```lua
OpenSkill.Ordinal(a1) --> 0
--after updating the rating above:
OpenSkill.Ordinal(a1) --> 2.3245624871094
```

<br>

If your teams are listed in one order but your ranking is in a different order, you can specify a ranks option, such as:
```lua
local a = OpenSkill.Rating()
local b = OpenSkill.Rating()
local c = OpenSkill.Rating()
local d = OpenSkill.Rating()

OpenSkill.Rate({{a}, {b}, {c}, {d}}, { --4 teams consisting of 1 player
	rank = {4, 1, 3, 2}
})
```
It is assumed that the lower ranks played better in the game, while higher ranks did worse.  For example, the team of `b` would be the best of the game.

<br>

You can also provide a score instead, where lower is worse and higher is better. These can just be raw scores from the game, if you want.
```lua
OpenSkill.Rate({{a}, {b}, {c}, {d}}, {
	score = {37, 19, 37, 42}
})
```
Ties should have either equivalent rank or score.

<br>

openskill.lua provides two rating models: `PlackettLuce` and `ThurstoneMosteller`.

- Plackett-Luce is a generalized Bradley-Terry model for k ≥ 3 teams which scales best. It follows a logistic distribution over a player's skill, similar to Glicko.
- Thurstone-Mosteller rating models follow a gaussian distribution, similar to TrueSkill. Gaussian CDF/PDF functions differ in implementation from system to system (they're all just chebyshev approximations anyway). The accuracy of this model isn't usually as great either, but tuning this with an alternative gamma function can improve the accuracy if you really want to get into it.
- openskill.lua uses full pairing which should have more accurate ratings over partial pairing, however in high k games (like 100+ teams), Bradley-Terry and Thurston-Mosteller models need to do a calculation of joint probability which involves a k-1 dimensional integration, which is computationally expensive. Partial pairing, where players only change based on their neighbors, is not available yet.

You can change the default model by changing `OpenSkill.Settings.DefaultModel`. Alternatively you can pass a model option to the `Rate` function:
```lua
OpenSkill.Rate({{a}, {b}, {c}, {d}}, {
	model = "ThurstoneMosteller"
})
```
More models are coming in the future.

<br>

Contributions are greatly appreciated!