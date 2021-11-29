local constants = {}

function constants.z(options)
	return options.z or 3
end

function constants.mu(options)
	return options.mu or 25
end

function constants.sigma(options)
	return options.sigma or constants.mu(options) / constants.z(options)
end

function constants.epsilon(options)
	return options.epsilon or 0.0001
end

function constants.beta(options)
	return options.beta or constants.sigma(options) / 2
end

function constants.betaSq(options)
	return constants.beta(options) ^ 2
end

return constants