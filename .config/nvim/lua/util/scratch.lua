local M = {}

local function find_named_buffer(name)
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_name(buf) == name then
			return buf
		end
	end
end

function M.open(opts)
	opts = opts or {}

	local title = opts.title or "Scratch"
	local lines = opts.lines or {}
	local filetype = opts.filetype or "markdown"
	local reuse = opts.reuse ~= false

	vim.cmd("botright split")

	local buf = reuse and find_named_buffer(title) or nil
	if not buf then
		buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_name(buf, title)
	end

	vim.api.nvim_win_set_buf(0, buf)
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].swapfile = false
	vim.bo[buf].modifiable = true
	vim.bo[buf].filetype = filetype

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
	vim.bo[buf].modified = false

	vim.wo.wrap = opts.wrap == true
	vim.wo.linebreak = opts.linebreak == true
	vim.wo.cursorline = opts.cursorline == true

	vim.keymap.set("n", "q", "<cmd>close<cr>", {
		buffer = buf,
		silent = true,
		desc = "Close " .. title,
	})

	return buf
end

return M
