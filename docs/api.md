## Settings
#### DefaultModel
```lua
DefaultModel : string
```
Determines the model which is used by default.
---
## Functions
#### Rating
```lua
Rating(mu : number?, sigma : number?, options : any?): rating
```
Creates a rating object, which describes a player's skill. Ratings are kept as an object which represent a gaussian curve, with properties where `mu` represents the mean, and `sigma` represents the spread or standard deviation. `mu` is the average skill of the player and `sigma` is the degree of uncertainty in the player's skill. Maintaining an uncertainty allows the system to make big changes to the skill estimates early on but small changes after a series of consistent games has been played.
---
#### Ordinal
```lua
Ordinal(rating : rating, options : any?): number
```
Represents a player's skill estimate by one number. By default, this returns `mu - 3 * sigma`, showing a rating for which there's a [99.7%](https://en.wikipedia.org/wiki/68–95–99.7_rule) likelihood the player's true rating is higher. So in early games, a player's ordinal rating will usually go up and could go up even if that player loses.
---
#### Rate
```lua
Rate(teams : {{rating}}, options : any?): {{{number}}}
```
Updates the values of the ratings and returns the result in arrays.
---
#### WinProbability
```lua
WinProbability(teams : {{rating}}, options : any?): {number}
```
Calculates the probability of each team winning.
---
#### DrawProbability

Not available yet.