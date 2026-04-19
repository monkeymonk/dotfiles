local M = {}

local function emit(level, scope, message)
	if scope and scope ~= "" then
		message = ("%s: %s"):format(scope, message)
	end

	vim.notify(message, level)
end

function M.info(scope, message)
	emit(vim.log.levels.INFO, scope, message)
end

function M.warn(scope, message)
	emit(vim.log.levels.WARN, scope, message)
end

function M.error(scope, message)
	emit(vim.log.levels.ERROR, scope, message)
end

return M
