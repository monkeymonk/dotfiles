local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local group_general = augroup("user_general", { clear = true })
local group_numbers = augroup("user_numbers", { clear = true })
local group_markdown = augroup("user_markdown", { clear = true })
local group_terminal = augroup("user_terminal", { clear = true })
local group_php = augroup("user_php", { clear = true })

vim.api.nvim_create_user_command("Q", "qa", {})

autocmd("FileType", {
	group = group_general,
	pattern = { "json", "jsonc", "markdown" },
	callback = function()
		vim.opt_local.conceallevel = 0
	end,
})

autocmd("BufReadPost", {
	group = group_general,
	callback = function(args)
		local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
		local lcount = vim.api.nvim_buf_line_count(args.buf)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

autocmd("BufWritePre", {
	group = group_general,
	callback = function(args)
		if vim.bo[args.buf].binary then
			return
		end

		local excluded = {
			diff = true,
			gitcommit = true,
			markdown = true,
		}

		if excluded[vim.bo[args.buf].filetype] then
			return
		end

		local view = vim.fn.winsaveview()
		vim.cmd([[keepjumps keeppatterns %s/\s\+$//e]])
		vim.fn.winrestview(view)
	end,
})

autocmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter" }, {
	group = group_numbers,
	callback = function()
		if vim.wo.number and vim.bo.buftype == "" then
			vim.wo.relativenumber = true
		end
	end,
})

autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
	group = group_numbers,
	callback = function()
		if vim.wo.number then
			vim.wo.relativenumber = false
		end
	end,
})

autocmd("FileType", {
	group = group_markdown,
	pattern = { "markdown", "text", "gitcommit" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.spell = true
		vim.opt_local.spelllang = { "en_us" }
		vim.opt_local.conceallevel = 0
	end,
})

autocmd("FileType", {
	group = group_markdown,
	pattern = { "gitcommit", "gitrebase" },
	callback = function()
		vim.cmd("startinsert")
	end,
})

autocmd("TermOpen", {
	group = group_terminal,
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.signcolumn = "no"
	end,
})

autocmd("FileType", {
	group = group_php,
	pattern = "php",
	callback = function()
		vim.opt_local.iskeyword:append("$")
		vim.opt_local.tabstop = 4
		vim.opt_local.shiftwidth = 4
		vim.opt_local.softtabstop = 4
	end,
})
