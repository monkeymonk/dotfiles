local M = {}

local notify = require("util.notify")

local state = {
	items = {},
	next_id = 1,
}

local function current_entry()
	local buf = vim.api.nvim_get_current_buf()
	local file = vim.api.nvim_buf_get_name(buf)
	if file == "" then
		return nil
	end

	local pos = vim.api.nvim_win_get_cursor(0)
	local line = vim.api.nvim_buf_get_lines(buf, pos[1] - 1, pos[1], false)[1] or ""

	return {
		id = state.next_id,
		file = vim.fs.normalize(file),
		row = pos[1],
		col = pos[2],
		text = vim.trim(line),
	}
end

local function jump(entry)
	if not entry then
		return
	end
	vim.cmd.edit(vim.fn.fnameescape(entry.file))
	pcall(vim.api.nvim_win_set_cursor, 0, { entry.row, entry.col })
end

local function list_items()
	local items = {}
	for index, entry in ipairs(state.items) do
		items[#items + 1] = {
			idx = index,
			entry = entry,
			text = string.format("%d. %s:%d", index, vim.fn.fnamemodify(entry.file, ":~:."), entry.row),
			preview = { text = entry.text ~= "" and entry.text or "[blank line]" },
		}
	end
	return items
end

function M.add_current()
	local entry = current_entry()
	if not entry then
		notify.warn("Markers", "Current buffer has no file on disk")
		return
	end

	state.items[#state.items + 1] = entry
	state.next_id = state.next_id + 1
	notify.info("Markers", ("Added %s:%d"):format(vim.fn.fnamemodify(entry.file, ":~:."), entry.row))
end

function M.pick()
	local items = list_items()
	if #items == 0 then
		notify.info("Markers", "No markers")
		return
	end

	require("snacks").picker({
		title = "Markers",
		items = items,
		format = function(item)
			return { { item.text } }
		end,
		preview = "preview",
		confirm = function(picker, item)
			picker:close()
			if item then
				jump(item.entry)
			end
		end,
	})
end

function M.remove()
	local items = list_items()
	if #items == 0 then
		notify.info("Markers", "No markers")
		return
	end

	vim.ui.select(items, {
		prompt = "Remove marker:",
		format_item = function(item)
			return item.text
		end,
	}, function(choice)
		if not choice then
			return
		end
		table.remove(state.items, choice.idx)
		notify.info("Markers", "Removed marker")
	end)
end

function M.next()
	if #state.items == 0 then
		notify.info("Markers", "No markers")
		return
	end

	local file = vim.fs.normalize(vim.api.nvim_buf_get_name(0))
	local row = vim.api.nvim_win_get_cursor(0)[1]
	for _, entry in ipairs(state.items) do
		if entry.file > file or (entry.file == file and entry.row > row) then
			jump(entry)
			return
		end
	end
	jump(state.items[1])
end

function M.prev()
	if #state.items == 0 then
		notify.info("Markers", "No markers")
		return
	end

	local file = vim.fs.normalize(vim.api.nvim_buf_get_name(0))
	local row = vim.api.nvim_win_get_cursor(0)[1]
	for i = #state.items, 1, -1 do
		local entry = state.items[i]
		if entry.file < file or (entry.file == file and entry.row < row) then
			jump(entry)
			return
		end
	end
	jump(state.items[#state.items])
end

return M
