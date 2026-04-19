local M = {}

local notify = require("util.notify")

local cleanup_group
local tempfiles = {}

local function packadd(name)
	pcall(vim.cmd.packadd, name)
end

local function ensure_cleanup()
	if cleanup_group then
		return
	end

	cleanup_group = vim.api.nvim_create_augroup("user_native_tools", { clear = true })
	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = cleanup_group,
		callback = function()
			for path in pairs(tempfiles) do
				pcall(vim.uv.fs_unlink, path)
			end
		end,
	})
end

local function git(args, cwd)
	local result = vim.system(vim.list_extend({ "git", "-C", cwd }, args), { text = true }):wait()
	if result.code ~= 0 then
		error(vim.trim(result.stderr or result.stdout or "git command failed"))
	end
	return result.stdout
end

local function git_root(file)
	local dir = vim.fs.dirname(file)
	local ok, root = pcall(git, { "rev-parse", "--show-toplevel" }, dir)
	if not ok or not root or root == "" then
		return nil
	end
	return vim.fs.normalize(vim.trim(root))
end

local function write_tempfile(name, content)
	local dir = vim.fs.joinpath(vim.fn.stdpath("cache"), "difftool")
	vim.fn.mkdir(dir, "p")

	local path = vim.fs.joinpath(dir, name)
	local fd = assert(vim.uv.fs_open(path, "w", 420))
	assert(vim.uv.fs_write(fd, content, -1))
	assert(vim.uv.fs_close(fd))

	tempfiles[path] = true
	ensure_cleanup()
	return path
end

function M.open_undotree()
	packadd("nvim.undotree")
	vim.cmd.Undotree()
end

function M.open_difftool(left, right)
	packadd("nvim.difftool")
	require("difftool").open(vim.fs.normalize(left), vim.fs.normalize(right))
end

function M.diff_current_file(ref)
	ref = ref or "HEAD"

	local file = vim.api.nvim_buf_get_name(0)
	if file == "" then
		notify.warn("Git", "Current buffer has no file on disk")
		return
	end

	file = vim.fs.normalize(vim.fn.fnamemodify(file, ":p"))
	local root = git_root(file)
	if not root then
		notify.warn("Git", "Current file is not inside a Git worktree")
		return
	end

	local rel = vim.fs.relpath(root, file)
	if not rel then
		notify.error("Git", "Failed to resolve file path relative to Git root")
		return
	end

	local ok, blob = pcall(git, { "show", ("%s:%s"):format(ref, rel) }, root)
	if not ok then
		notify.warn("Git", ("Object not available for %s:%s"):format(ref, rel))
		return
	end

	local safe_ref = ref:gsub("[^%w%-_.]", "_")
	local tmp = write_tempfile(("%s__%s"):format(safe_ref, vim.fn.fnamemodify(file, ":t")), blob)
	M.open_difftool(tmp, file)
end

return M
