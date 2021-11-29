local util = require(script.Parent.Parent.Util)
local constants = require(script.Parent.Parent.Constants)
local statistics = require(script.Parent.Parent.Statistics)

return function(game_, options)
	options = options or {}
	local twoBetaSq = constants.betaSq(options) * 2
	local epsilon = constants.epsilon(options)
	local teamRatings = util.teamRating(game_, options)
	local result = {}
	for i, iTeamRating in ipairs(teamRatings) do
		local iMu, iSigmaSq, iTeam, iRank = unpack(iTeamRating)	
		local iOmega, iDelta = 0, 0
		for q, qTeamRating in ipairs(teamRatings) do
			local qMu, qSigmaSq, qTeam, qRank = unpack(qTeamRating)
			if i == q then continue end		
			local ciq = math.sqrt(iSigmaSq + qSigmaSq + twoBetaSq)
			local deltaMu = (iMu - qMu) / ciq
			local sigSqToCiq = iSigmaSq / ciq
			local iGamma = util.gamma(ciq, iSigmaSq)		
			if qRank > iRank then
				iOmega += sigSqToCiq * statistics.v(deltaMu, epsilon / ciq)
				iDelta += (iGamma * sigSqToCiq / ciq * 
					statistics.w(deltaMu, epsilon / ciq))
			elseif qRank < iRank then
				iOmega += -sigSqToCiq * statistics.v(-deltaMu, epsilon / ciq)
				iDelta += (iGamma * sigSqToCiq / ciq * 
					statistics.w(-deltaMu, epsilon / ciq))
			else
				iOmega += sigSqToCiq * statistics.vt(deltaMu, epsilon / ciq)
				iDelta += ((iGamma * sigSqToCiq) / ciq) * 
					statistics.wt(deltaMu, epsilon / ciq)
			end
		end	
		local intermediate = {}
		for _, v in ipairs(iTeam) do
			table.insert(intermediate, {v.mu + (v.sigma ^ 2 / iSigmaSq) * iOmega,
				v.sigma * math.sqrt(math.max(1 - (v.sigma ^ 2 / iSigmaSq) * iDelta, epsilon))})
		end
		result[i] = intermediate
	end
	return result
end