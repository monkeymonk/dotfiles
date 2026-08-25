-- Auto-wires quickfix-integrated commands for Composer/Bedrock PHP projects.
-- Generalizes the pattern every such repo used to duplicate in its own
-- `.nvim.lua`: if a given vendor/bin tool exists at the project root, expose
-- a `:Command` that runs it and dumps results into the quickfix list.
local M = {}

local uv = vim.uv or vim.loop

local function exists(p)
	return uv.fs_stat(p) ~= nil
end

-- Walk up from `start` looking for composer.json; fall back to cwd.
local function find_root(start)
	local dir = vim.fn.fnamemodify(start, ":p:h")
	while dir and dir ~= "/" do
		if exists(dir .. "/composer.json") then
			return dir
		end
		local parent = vim.fn.fnamemodify(dir, ":h")
		if parent == dir then
			break
		end
		dir = parent
	end
	return vim.fn.getcwd()
end

local function run_make(cmd, efm)
	vim.opt.makeprg = cmd
	if efm then
		vim.opt.errorformat = efm
	end
	vim.cmd("make")
end

local defined_for = {}

-- Idempotent: safe to call repeatedly (VimEnter, DirChanged, FileType).
function M.setup()
	local root = find_root(vim.fn.getcwd())
	if defined_for[root] then
		return
	end
	defined_for[root] = true

	local function cd_cmd(bin_cmd)
		return ("cd %s && %s"):format(vim.fn.fnameescape(root), bin_cmd)
	end

	if exists(root .. "/vendor/bin/phpstan") then
		vim.api.nvim_create_user_command("Stan", function()
			run_make(cd_cmd("./vendor/bin/phpstan analyse --error-format=raw"), [[%f:%l:%m]])
		end, { desc = "PHPStan -> quickfix" })
	end

	if exists(root .. "/vendor/bin/phpcs") then
		vim.api.nvim_create_user_command("CS", function()
			run_make(cd_cmd("./vendor/bin/phpcs --report=emacs"), [[%f:%l:%c: %m]])
		end, { desc = "PHPCS -> quickfix" })
	end

	if exists(root .. "/vendor/bin/phpcbf") then
		vim.api.nvim_create_user_command("FixCS", function()
			run_make(cd_cmd("./vendor/bin/phpcbf"), nil)
		end, { desc = "PHPCBF" })
	end

	if exists(root .. "/vendor/bin/phpunit") then
		vim.api.nvim_create_user_command("Test", function()
			run_make(cd_cmd("./vendor/bin/phpunit --colors=never"), [[%f:%l: %m]])
		end, { desc = "PHPUnit -> quickfix" })
	end

	-- Acorn (Roots/Bedrock/Sage) convenience commands, only when the
	-- package is actually installed and WP-CLI is available.
	if vim.fn.executable("wp") == 1 and exists(root .. "/vendor/roots/acorn") then
		vim.api.nvim_create_user_command("AcornClear", function()
			run_make(cd_cmd("wp acorn optimize:clear"), nil)
		end, { desc = "wp acorn optimize:clear" })
		vim.api.nvim_create_user_command("AcornViewCache", function()
			run_make(cd_cmd("wp acorn view:cache"), nil)
		end, { desc = "wp acorn view:cache" })
	end
end

return M
