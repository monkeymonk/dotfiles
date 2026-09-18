local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local group_general = augroup("user_general", { clear = true })
local group_numbers = augroup("user_numbers", { clear = true })
local group_markdown = augroup("user_markdown", { clear = true })
local group_terminal = augroup("user_terminal", { clear = true })
local group_php = augroup("user_php", { clear = true })
local group_php_tools = augroup("user_php_tools", { clear = true })

vim.api.nvim_create_user_command("Q", "qa", {})

local function detach_reattach_command()
	local server = vim.v.servername
	if server == nil or server == "" then
		return nil
	end
	return string.format("nvim --server %s --remote-ui", vim.fn.shellescape(server))
end

local function detach_with_confirmation()
	local reattach_cmd = detach_reattach_command()
	if reattach_cmd == nil then
		require("util.notify").warn("Detach", "No server address available; not detaching")
		return
	end

	pcall(vim.fn.setreg, "+", reattach_cmd)

	vim.api.nvim_echo({
		{ "Reattach with:\n", "MoreMsg" },
		{ reattach_cmd, "Question" },
		{ "\n\nPress <Enter> to detach, <Esc> to cancel: ", "MoreMsg" },
	}, false, {})

	local ok, key = pcall(vim.fn.getcharstr)
	if not ok or key == vim.api.nvim_replace_termcodes("<Esc>", true, false, true) or key == "\3" then
		vim.api.nvim_echo({ { "\nDetach cancelled", "MoreMsg" } }, false, {})
		return
	end
	if key ~= "\r" and key ~= "\n" then
		vim.api.nvim_echo({ { "\nDetach cancelled", "MoreMsg" } }, false, {})
		return
	end

	vim.cmd("detach")
end

vim.api.nvim_create_user_command("Detach", detach_with_confirmation, {
	desc = "Detach from this Neovim server, showing the reattach command first",
})

vim.cmd([[cnoreabbrev <expr> detach (getcmdtype() == ':' && getcmdline() == 'detach') ? 'Detach' : 'detach']])

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
		vim.opt_local.spelllang = { "en_us", "fr" }
		vim.opt_local.conceallevel = 0
	end,
})

autocmd("FileType", {
	group = group_markdown,
	pattern = "gitcommit",
	callback = function()
		if vim.fn.line(".") == 1 and vim.fn.getline(1) == "" then
			vim.cmd("startinsert")
		end
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

autocmd({ "VimEnter", "DirChanged" }, {
	group = group_php_tools,
	callback = function()
		require("util.php_project").setup()
	end,
})

local group_scratchpad = augroup("user_scratchpad", { clear = true })

local function fixup_scratchpad_buffer(buf)
	if not vim.g.scratchpad then
		return
	end
	local name = vim.api.nvim_buf_get_name(buf)
	if not name:match("nvim%-scratch") or not name:match("%.md$") then
		return
	end
	if vim.bo[buf].filetype ~= "markdown" then
		vim.bo[buf].filetype = "markdown"
	end
	vim.keymap.set("n", "q", function()
		vim.schedule(function()
			pcall(function()
				require("lualine").refresh({ place = { "statusline" } })
			end)
		end)
		if vim.fn.reg_recording() == "" then
			return "qq"
		end
		return "q"
	end, {
		buffer = buf,
		expr = true,
		nowait = true,
		desc = "Toggle macro recording in q register",
	})
end

autocmd({ "BufReadPost", "BufNewFile", "BufEnter" }, {
	group = group_scratchpad,
	pattern = "*.md",
	callback = function(args)
		fixup_scratchpad_buffer(args.buf)
	end,
})
