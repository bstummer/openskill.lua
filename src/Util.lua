local constants = require(script.Parent.Constants)
local util = {}

function util.score(q, i)
	if q < i then
		return 0
	elseif q > i then
		return 1
	end
	return 0.5
end

function util.rankings(teams, rank)
	rank = rank or {}
	local teamScores = {}
	for i in ipairs(teams) do
		table.insert(teamScores, rank[i] or i)
	end
	local outRank = {}
	local s = 1
	for i = 1, #teamScores do
		if i > 1 and teamScores[i-1] < teamScores[i] then
			s = i
		end
		outRank[i] = s
	end
	for i, v in ipairs(outRank) do --probably not needed
		outRank[i] -= 1
	end
	return outRank
end

function util.teamRating(game_, options)
	local rank = util.rankings(game_, options.rank)
	local result = {}
	for i, team in ipairs(game_) do
		local mu, sigma = 0, 0
		for _, v in ipairs(team) do
			mu += v.mu
			sigma += v.sigma ^ 2
		end
		table.insert(result, {mu, sigma, team, rank[i]})
	end
	return result
end

function util.ladderPairs(ranks)
	local size = #ranks
	if size == 0 then
		return {{}}
	end
	local left = {}
	table.move(ranks, 1, size - 1, 2, left)
	local right = {}
	table.move(ranks, 2, size, 1, right)
	local zip = {}
	for i = 1, size do
		if left[i] then
			table.insert(zip, {left[i], right[i]})
		else
			table.insert(zip, {right[i]})
		end
	end
	return zip
end

function util.c(teamRatings, options)
	local betaSq = constants.betaSq(options)
	local teamSigmaSq = 0
	for _, v in ipairs(teamRatings) do
		teamSigmaSq += v[2] + betaSq
	end
	return math.sqrt(teamSigmaSq)
end

function util.sumQ(teamRatings, c)
	local result = {}
	for _, q in ipairs(teamRatings) do
		local sum = 0
		for _, i in ipairs(teamRatings) do
			if i[4] >= q[4] then
				sum += math.exp(i[1] / c)
			end
		end
		table.insert(result, sum)
	end
	return result
end

function util.a(teamRatings)
	local result = {}
	for _, i in ipairs(teamRatings) do
		local arr = {}
		for _, q in ipairs(teamRatings) do
			if i[4] == q[4] then
				table.insert(arr, q)
			end
		end
		table.insert(result, #arr)
	end
	return result
end

--[[
These would actually be the args passed: c, k, mu, sigmaSq, team, qRank
Instead only these are passed: c, sigmaSq, options
If this is a problem for you when using a custom gamma function,
please message me and i will fix it :)
]]
function util.gamma(c, sigmaSq, options)
	if options and options.gamma then
		return options.gamma(c, sigmaSq, options)
	end
	return math.sqrt(sigmaSq) / c
end

--https://www.npmjs.com/package/sort-unwind
function util.unwind(t:{any},order:{number}):({any},{number})
	local sorted, tenet, newOrder = {}, {}, {}
	local handledIndexes = {}
	for i = 1, #order do
		local nextLowest = math.huge
		local index
		for idx, v in ipairs(order) do
			if not table.find(handledIndexes, idx) then
				if v < nextLowest then
					nextLowest = v
					index = idx
				end
			end
		end
		table.insert(handledIndexes, index)
		newOrder[index] = i
	end
	for i, v in ipairs(t) do
		sorted[newOrder[i]] = v
		tenet[newOrder[i]] = i
	end
	return sorted, tenet
end

return util