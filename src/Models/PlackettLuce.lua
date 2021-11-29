local util = require(script.Parent.Parent.Util)
local constants = require(script.Parent.Parent.Constants)

return function(game_, options)
	options = options or {}
	local epsilon = constants.epsilon(options)
	local teamRatings = util.teamRating(game_, options)
	local c = util.c(teamRatings, options)
	local sumQ = util.sumQ(teamRatings, c)
	local a = util.a(teamRatings)
	local result = {}
	for i, iTeamRating in ipairs(teamRatings) do
		local iMu, iSigmaSq, iTeam, iRank = unpack(iTeamRating)
		local iMuOverCe = math.exp(iMu / c)
		local omegaSum, deltaSum = 0, 0
		for q, v in ipairs(teamRatings) do
			if v[4] <= iRank then
				local quotient = iMuOverCe / sumQ[q]
				if i == q then
					omegaSum += (1 - quotient) / a[q]
				else
					omegaSum += -quotient / a[q]
				end
				deltaSum += (quotient * (1 - quotient)) / a[q]
			end
		end	
		local iGamma = util.gamma(c, iSigmaSq, options)
		local iOmega = omegaSum * (iSigmaSq / c)
		local iDelta = iGamma * deltaSum * (iSigmaSq / c ^ 2)	
		local intermediate = {}
		for _, v in ipairs(iTeam) do
			table.insert(intermediate, {v.mu + (v.sigma ^ 2 / iSigmaSq) * iOmega,
				v.sigma * math.sqrt(math.max(1 - (v.sigma ^ 2 / iSigmaSq) * iDelta, epsilon))})
		end
		result[i] = intermediate
	end
	return result
end