local M = {}

local notify = require("util.notify")
local stubs = require("config.php_stubs")

local function notify_stub_status()
	local status = stubs.status()
	local installed = status.installed

	if #installed == 0 then
		notify.info("PHP stubs", "None installed in " .. status.stub_path)
		return
	end

	local names = {}
	for _, path in ipairs(installed) do
		names[#names + 1] = vim.fn.fnamemodify(path, ":t")
	end

	notify.info("PHP stubs", table.concat(names, ", "))
end

function M.setup()
	vim.api.nvim_create_user_command("LspInstall", function()
		if vim.fn.exists(":Mason") == 0 then
			notify.warn("LSP", "Mason is not available")
			return
		end
		vim.cmd.Mason()
	end, { desc = "Open Mason to install configured LSP servers" })

	vim.api.nvim_create_user_command("PhpStubsInstall", function()
		stubs.ensure_php_stubs()
	end, { desc = "Install configured PHP stubs" })

	vim.api.nvim_create_user_command("PhpStubsStatus", function()
		notify_stub_status()
	end, { desc = "Show installed PHP stubs" })
end

return M
