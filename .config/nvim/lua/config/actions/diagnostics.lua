local M = {}

local notify = require("util.notify")
local quicklist = require("util.quicklist")

function M.to_loclist()
	vim.diagnostic.setloclist()
end

function M.to_qflist()
	vim.diagnostic.setqflist()
	quicklist.open_qf()
end

function M.toggle_buffer()
	local bufnr = vim.api.nvim_get_current_buf()
	local enabled = vim.diagnostic.is_enabled({ bufnr = bufnr })

	vim.diagnostic.enable(not enabled, { bufnr = bufnr })
	notify.info("Diagnostics", enabled and "Disabled for current buffer" or "Enabled for current buffer")
end

return M
