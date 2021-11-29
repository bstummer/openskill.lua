--Based on errcw/gaussian commit 40
--https://www.npmjs.com/package/gaussian

type n = number

local function erfc(x:n):n
	local z = math.abs(x)
	local t = 1 / (1 + z / 2)
	local r = t * math.exp(-z * z - 1.26551223 + t * (1.00002368 +
		t * (0.37409196 + t * (0.09678418 + t * (-0.18628806 +
			t * (0.27886807 + t * (-1.13520398 + t * (1.48851587 +
				t * (-0.82215223 + t * 0.17087277)))))))))
	return x < 0 and 2 - r or r
end

local function ierfc(x:n):n
	if x >= 2 then return -100 end
	if x <= 0 then return 100 end	
	local xx = x < 1 and x or 2 - x
	local t = math.sqrt(-2 * math.log(xx / 2))
	local r = -0.70711 * ((2.30753 + t * 0.27061) /
		(1 + t * (0.99229 + t * 0.04481)) - t)
	for i = 1, 2 do
		local err = erfc(r) - xx
		r += err / (1.12837916709551257 * math.exp(-(r * r)) - r * err)
	end
	return x < 1 and r or -r
end

local gaussian = {}
gaussian.__index = gaussian

local function fromPrecisionMean(precision:n, precisionMean:n)
	return gaussian.new(precisionMean / precision, 1 / precision)
end

gaussian.__mul = function(self, d)
	if type(d) == "number" then
		return self:scale(d)
	end
	local precision = 1 / self.variance
	local dprecision = 1 / d.variance
	return fromPrecisionMean(
		precision + dprecision, 
		precision * self.mean + dprecision * d.mean)
end

gaussian.__div = function(self, d)
	if type(d) == "number" then
		return self:scale(1 / d)
	end
	local precision = 1 / self.variance
	local dprecision = 1 / d.variance
	return fromPrecisionMean(
		precision - dprecision, 
		precision * self.mean - dprecision * d.mean)
end

gaussian.__add = function(self, d)
	if type(d) == "number" then
		error("Only gaussians can be added")
	end
	return gaussian.new(self.mean + d.mean, self.variance + d.variance)
end

gaussian.__sub = function(self, d)
	if type(d) == "number" then
		error("Only gaussians can be subtracted")
	end
	return gaussian.new(self.mean - d.mean, self.variance + d.variance)
end

function gaussian.new(mean:n, variance:n)
	if variance <= 0 then
		error("Variance must be > 0, but is "..variance)
	end
	local self = {}
	self.mean = mean --mean μ
	self.variance = variance --variance σ^2
	self.standardDeviation = math.sqrt(variance) --standard deviation σ
	return setmetatable(self, gaussian)
end

--returns an array of generated n random samples correspoding
--to the Gaussian parameters
function gaussian:random(num:n)
	local _2pi = math.pi * 2
	local mean, std = self.mean, self.standardDeviation
	local result = {}
	for i = 1, num do
		table.insert(result, (math.sqrt(-2 * math.log(math.random())) *
			math.cos(_2pi * math.random())) * std + mean)
	end
	return result
end

--the probability density function, which describes the probability
--of a random variable taking on the value x
function gaussian:pdf(x:n):n
	return math.exp(-math.pow(x - self.mean, 2) / (2 * self.variance))
		/ (self.standardDeviation * math.sqrt(2 * math.pi))
end

--the cumulative distribution function, which describes the probability
--of a random variable falling in the interval [−∞, x]
function gaussian:cdf(x:n):n
	return 0.5 * erfc(-(x - self.mean) / (self.standardDeviation * math.sqrt(2)))
end

--the percent point function, the inverse of cdf
function gaussian:ppf(x:n):n
	return self.mean - self.standardDeviation * math.sqrt(2) * ierfc(2 * x)
end

function gaussian:scale(c:n)
	return gaussian.new(self.mean * c, self.variance * c * c)
end

return gaussian