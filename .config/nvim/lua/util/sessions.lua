local M = {}

local notify = require("util.notify")

local session_dir = vim.fn.stdpath("state") .. "/named_sessions/"

local function ensure_dir()
	vim.fn.mkdir(session_dir, "p")
end

local function cwd_dir()
	return session_dir .. vim.fn.getcwd():gsub("[\\/:]+", "%%") .. "/"
end

--- Save current session with a name
function M.save(name)
	ensure_dir()
	vim.fn.mkdir(cwd_dir(), "p")
	local path = cwd_dir() .. name .. ".vim"
	vim.cmd("mks! " .. vim.fn.fnameescape(path))
	notify.info("Sessions", "Saved " .. name)
end

--- Load a named session
function M.load(name)
	local path = cwd_dir() .. name .. ".vim"
	if vim.fn.filereadable(path) == 1 then
		vim.cmd("silent! source " .. vim.fn.fnameescape(path))
		notify.info("Sessions", "Loaded " .. name)
	else
		notify.warn("Sessions", "Not found: " .. name)
	end
end

--- Delete a named session
function M.delete(name)
	local path = cwd_dir() .. name .. ".vim"
	if vim.fn.filereadable(path) == 1 then
		vim.fn.delete(path)
		notify.info("Sessions", "Deleted " .. name)
	end
end

--- List named sessions for the current directory
function M.list()
	local dir = cwd_dir()
	local files = vim.fn.glob(dir .. "*.vim", false, true)
	local names = {}
	for _, f in ipairs(files) do
		names[#names + 1] = vim.fn.fnamemodify(f, ":t:r")
	end
	table.sort(names)
	return names
end

return M
