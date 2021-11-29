--[[

Tutorial & Documentation: 

Version of this module: 1.0.0
Based on philihp/openskill.js commit 267

Ported to Lua & improved by Vaschex

]]

local module = {}
module.Settings = {
	DefaultModel = "PlackettLuce"
}

--[[
The MIT License (MIT)

Copyright (c) 2020 Philihp Busby <philihp@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]

---------------------------------------------------------

local constants = require(script.Constants)
local gaussian = require(script.Gaussian)
local statistics = require(script.Statistics)
local util = require(script.Util)
local models = require(script.Models)

type rating = {
	mu: number,
	sigma: number
}

function module.Ordinal(rating:rating, options:any?):number
	options = options or {}
	return rating.mu - constants.z(options) * rating.sigma
end

function module.Rating(mu:number?, sigma:number?, options:any?):rating
	options = options or {}
	local copy = {} --copy because i dont want to change the options table
	for k, v in next, options do
		copy[k] = v
	end
	copy.mu = mu
	return {
		mu = mu or constants.mu(options),
		sigma = sigma or constants.sigma(copy)
	}
end

function module.Rate(teams:{{rating}}, options:any?):{{{number}}}
	options = options or {}
	local model = models[options.model or module.Settings.DefaultModel]
	if options.rank == nil and options.score == nil then
		local result = model(teams, options)
		for i, v in ipairs(result) do
			for i2, v2 in ipairs(v) do
				teams[i][i2].mu = v2[1]
				teams[i][i2].sigma = v2[2]
			end
		end
		return result
	end
	local rank = options.rank
	if not rank then
		rank = {}
		for i, v in ipairs(options.score) do
			rank[i] = -v
		end
	end
	local orderedTeams, tenet = util.unwind(teams, rank)
	local newOptions = {}
	for i, v in next, options do
		newOptions[i] = v
	end
	table.sort(rank)
	newOptions.rank = rank
	local newRatings = model(orderedTeams, newOptions)
	local reorderedTeams = util.unwind(newRatings, tenet)
	for i, v in ipairs(reorderedTeams) do
		for i2, v2 in ipairs(v) do
			teams[i][i2].mu = v2[1]
			teams[i][i2].sigma = v2[2]
		end
	end
	return reorderedTeams
end

--only works for 2 teams, pls message me if you have a general solution
function module.WinProbability(a:{rating}, b:{rating}, options:any?):number
	options = options or {}
	local muA, sigmaA = 0, 0
	for _, v in ipairs(a) do
		muA += v.mu
		sigmaA += v.sigma ^ 2
	end
	local muB, sigmaB = 0, 0
	for _, v in ipairs(b) do
		muB += v.mu
		sigmaB += v.sigma ^ 2
	end
	return statistics.phiMajor((muA - muB) / math.sqrt((#a + #b) *
		constants.betaSq(options) + (sigmaA + sigmaB)))
end

--function module.DrawProbability(teams:{{rating}}, options:any?):number

--end

return module