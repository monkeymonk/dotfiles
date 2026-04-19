local M = {}

local notify = require("util.notify")
local scratch = require("util.scratch")

local doc_path = vim.fn.stdpath("config") .. "/docs/memory-sheet.md"

local function collect_sections(lines)
	local sections = {}
	for lnum, line in ipairs(lines) do
		local hashes, title = line:match("^(##+) (.+)$")
		if hashes and title then
			sections[#sections + 1] = {
				lnum = lnum,
				level = #hashes,
				title = title,
			}
		end
	end
	return sections
end

local function jump_to(buf, lnum)
	if not vim.api.nvim_buf_is_valid(buf) then
		return
	end

	local win = vim.fn.bufwinid(buf)
	if win == -1 then
		return
	end

	vim.api.nvim_set_current_win(win)
	pcall(vim.api.nvim_win_set_cursor, win, { lnum, 0 })
	vim.cmd("normal! zz")
end

local function jump_relative(buf, direction)
	local cursor = vim.api.nvim_win_get_cursor(0)[1]
	local sections = collect_sections(vim.api.nvim_buf_get_lines(buf, 0, -1, false))

	if #sections == 0 then
		notify.info("Memory Sheet", "No sections found")
		return
	end

	if direction > 0 then
		for _, section in ipairs(sections) do
			if section.lnum > cursor then
				jump_to(buf, section.lnum)
				return
			end
		end
		jump_to(buf, sections[1].lnum)
		return
	end

	for index = #sections, 1, -1 do
		local section = sections[index]
		if section.lnum < cursor then
			jump_to(buf, section.lnum)
			return
		end
	end

	jump_to(buf, sections[#sections].lnum)
end

local function pick_section(buf)
	local sections = collect_sections(vim.api.nvim_buf_get_lines(buf, 0, -1, false))
	if #sections == 0 then
		notify.info("Memory Sheet", "No sections found")
		return
	end

	local ok, snacks = pcall(require, "snacks")
	if ok then
		snacks.picker({
			title = "Memory Sheet Sections",
			items = sections,
			format = function(item)
				local indent = string.rep("  ", math.max(item.level - 2, 0))
				return { { indent .. item.title } }
			end,
			confirm = function(picker, item)
				picker:close()
				if item then
					jump_to(buf, item.lnum)
				end
			end,
		})
		return
	end

	vim.ui.select(sections, {
		prompt = "Memory Sheet section:",
		format_item = function(item)
			return string.rep("  ", math.max(item.level - 2, 0)) .. item.title
		end,
	}, function(choice)
		if choice then
			jump_to(buf, choice.lnum)
		end
	end)
end

local function set_keymaps(buf)
	vim.keymap.set("n", "]]", function()
		jump_relative(buf, 1)
	end, { buffer = buf, silent = true, desc = "Next section" })

	vim.keymap.set("n", "[[", function()
		jump_relative(buf, -1)
	end, { buffer = buf, silent = true, desc = "Previous section" })

	vim.keymap.set("n", "gs", function()
		pick_section(buf)
	end, { buffer = buf, silent = true, desc = "Pick section" })
end

function M.open()
	local lines = vim.fn.readfile(doc_path)
	local buf = scratch.open({
		title = "Memory Sheet",
		lines = lines,
		filetype = "markdown",
		reuse = true,
		wrap = true,
		linebreak = true,
		cursorline = true,
	})
	set_keymaps(buf)
end

return M
