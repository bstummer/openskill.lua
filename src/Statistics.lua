local statistics = {}
local gaussian = require(script.Parent.Gaussian)

local normal = gaussian.new(0, 1)

function statistics.phiMajor(x)
	return normal:cdf(x)
end

function statistics.phiMajorInverse(x)
	return normal:ppf(x)
end

function statistics.phiMinor(x)
	return normal:pdf(x)
end

function statistics.v(x, t)
	local xt = x - t
	local denom = statistics.phiMajor(xt)
	return if denom < 2.2204460492503e-16 then -xt else statistics.phiMinor(xt) / denom
end

function statistics.w(x, t)
	local xt = x - t
	local denom = statistics.phiMajor(xt)
	if denom < 2.2204460492503e-16 then
		return if x < 0 then 1 else 0
	end
	return statistics.v(x, t) * (statistics.v(x, t) + xt)
end

function statistics.vt(x, t)
	local xx = math.abs(x)
	local b = statistics.phiMajor(t - xx) - statistics.phiMajor(-t - xx)
	if b < 1e-5 then
		if x < 0 then return -x - t end
		return -x + t
	end
	local a = statistics.phiMinor(-t - xx) - statistics.phiMinor(t - xx)
	return (if x < 0 then -a else a) / b
end

function statistics.wt(x, t)
	local xx = math.abs(x)
	local b = statistics.phiMajor(t - xx) - statistics.phiMajor(-t - xx)
	return if b < 2.2204460492503e-16 then 1 else ((t - xx) * statistics.phiMinor(t - xx) +
		(t + xx) * statistics.phiMinor(-t - xx)) / b + statistics.vt(x, t) * statistics.vt(x, t)
end

return statistics