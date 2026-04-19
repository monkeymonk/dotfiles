local M = {}

local notify = require("util.notify")

local SCOPE = "Quicklist"

local function info(message)
	notify.info(SCOPE, message)
end

local function warn(message)
	notify.warn(SCOPE, message)
end

local function error(message)
	notify.error(SCOPE, message)
end

local function has_items(kind)
	if kind == "loclist" then
		return vim.fn.getloclist(0, { size = 0 }).size > 0
	end
	return vim.fn.getqflist({ size = 0 }).size > 0
end

local function qf_path(item)
	if item.bufnr and item.bufnr > 0 then
		local name = vim.api.nvim_buf_get_name(item.bufnr)
		if name ~= "" then
			return vim.fs.normalize(name)
		end
	end
	if item.filename and item.filename ~= "" then
		return vim.fs.normalize(vim.fn.fnamemodify(item.filename, ":p"))
	end
	return nil
end

local function qf_entries_from_picker(items)
	local qf = {}
	for _, item in ipairs(items) do
		qf[#qf + 1] = {
			filename = item.file or qf_path(item) or item.filename,
			bufnr = item.buf or item.bufnr,
			lnum = item.pos and item.pos[1] or item.lnum or 1,
			col = item.pos and (item.pos[2] + 1) or item.col or 1,
			end_lnum = item.end_pos and item.end_pos[1] or item.end_lnum,
			end_col = item.end_pos and (item.end_pos[2] + 1) or item.end_col,
			text = item.line or item.text or item.comment or item.label or item.name or item.detail,
			pattern = item.search or item.pattern,
			type = item.severity and ({ "E", "W", "I", "N" })[item.severity] or item.type,
			valid = true,
		}
	end
	return qf
end

local function wins(kind)
	local items = {}
	for _, win in ipairs(vim.fn.getwininfo()) do
		if win.quickfix == 1 then
			if kind == "loclist" and win.loclist == 1 then
				items[#items + 1] = win
			elseif kind == "quickfix" and win.loclist == 0 then
				items[#items + 1] = win
			end
		end
	end
	return items
end

function M.is_open(kind)
	local ok, quicker = pcall(require, "quicker")
	if ok then
		return quicker.is_open(kind == "loclist" and vim.api.nvim_get_current_win() or nil)
	end
	return #wins(kind) > 0
end

function M.toggle_qf()
	if not has_items("quickfix") then
		info("No entries in quickfix list")
		return
	end
	local ok, quicker = pcall(require, "quicker")
	if ok then
		quicker.toggle()
	else
		vim.cmd("cwindow")
	end
end

function M.toggle_ll()
	if not has_items("loclist") then
		info("No entries in location list")
		return
	end
	local ok, quicker = pcall(require, "quicker")
	if ok then
		quicker.toggle({ loclist = true })
	else
		vim.cmd("lwindow")
	end
end

function M.open_qf()
	if not has_items("quickfix") then
		info("No entries in quickfix list")
		return
	end
	local ok, quicker = pcall(require, "quicker")
	if ok then
		quicker.open()
	else
		vim.cmd("copen")
	end
end

function M.set_qf_from_picker(items)
	local qf = qf_entries_from_picker(items)
	if #qf == 0 then
		info("No picker results to send to quickfix")
		return
	end
	vim.fn.setqflist(qf, "r")
end

function M.open_qf_later()
	vim.schedule(function()
		if has_items("quickfix") then
			vim.cmd("botright copen")
		end
	end)
end

function M.jump(kind, direction)
	local cmd
	if kind == "loclist" then
		cmd = direction == "next" and "lnext" or "lprev"
	else
		cmd = direction == "next" and "cnext" or "cprev"
	end

	local ok, err = pcall(vim.cmd, cmd)
	if not ok then
		info(err)
	end
end

function M.grep_cwd(opts)
	opts = opts or {}
	local cwd = opts.cwd or vim.fn.expand("%:p:h")

	vim.ui.input({ prompt = ("Grep %s > "):format(cwd) }, function(input)
		if not input or input == "" then
			return
		end

		vim.cmd("silent grep! " .. vim.fn.shellescape(input) .. " " .. vim.fn.fnameescape(cwd))
		if has_items("quickfix") then
			vim.cmd("copen")
		else
			info(("No matches in %s"):format(cwd))
		end
	end)
end

function M.remove_qf_item(index)
	local qf = vim.fn.getqflist({ items = 0, idx = 0, title = 0, context = 0 })
	local items = qf.items or {}
	index = index or vim.fn.line(".")

	if #items == 0 then
		info("Quickfix list is empty")
		return
	end
	if index < 1 or index > #items then
		warn("Quickfix item out of range")
		return
	end

	table.remove(items, index)
	vim.fn.setqflist({}, "r", {
		items = items,
		title = qf.title,
		context = qf.context,
	})

	if #items == 0 then
		vim.cmd("cclose")
		info("Removed last quickfix item")
		return
	end

	local next_idx = math.min(index, #items)
	vim.cmd("copen")
	pcall(vim.cmd, "cc " .. next_idx)
end

local function qf_file_targets()
	local items = vim.fn.getqflist({ items = 0 }).items or {}
	local seen = {}
	local files = {}

	for _, item in ipairs(items) do
		if item.valid == 1 then
			local path = qf_path(item)
			if path and not seen[path] then
				seen[path] = true
				files[#files + 1] = {
					path = path,
					lnum = item.lnum > 0 and item.lnum or 1,
					col = item.col > 0 and (item.col - 1) or 0,
				}
			end
		end
	end

	return files
end

local function close_current_file()
	vim.cmd("silent! update")
	vim.cmd("bdelete")
end

function M.replace_in_qf_files()
	local files = qf_file_targets()
	if #files == 0 then
		info("Quickfix list has no valid files")
		return
	end

	local start_buf = vim.api.nvim_get_current_buf()
	local state = {
		applied = 0,
		skipped = 0,
		stopped = false,
	}

	local function finish()
		if vim.api.nvim_buf_is_valid(start_buf) and vim.api.nvim_buf_is_loaded(start_buf) then
			pcall(vim.api.nvim_set_current_buf, start_buf)
		end
		info(("Replace complete: %d applied, %d skipped"):format(state.applied, state.skipped))
	end

	local function run_files(substitute)
		local index = 1

		local function step()
			if state.stopped or index > #files then
				finish()
				return
			end

			local file = files[index]
			index = index + 1

			local existing = vim.fn.bufnr(file.path)
			if existing ~= -1 and vim.api.nvim_buf_is_loaded(existing) and vim.bo[existing].modified then
				warn(("Skipping modified buffer: %s"):format(vim.fn.fnamemodify(file.path, ":~:.")))
				state.skipped = state.skipped + 1
				vim.schedule(step)
				return
			end

			vim.cmd("edit " .. vim.fn.fnameescape(file.path))
			pcall(vim.api.nvim_win_set_cursor, 0, { file.lnum, file.col })
			vim.cmd("normal! zz")

			vim.ui.select({ "Yes", "No", "Quit" }, {
				prompt = ("Apply replace in %s?"):format(vim.fn.fnamemodify(file.path, ":~:.")),
			}, function(choice)
				if choice == "Yes" then
					local ok, err = pcall(vim.cmd, "silent keepjumps keeppatterns " .. substitute)
					if not ok then
						error(err)
						vim.cmd("edit!")
						close_current_file()
						state.stopped = true
						finish()
						return
					end
					state.applied = state.applied + 1
					close_current_file()
					vim.schedule(step)
				elseif choice == "No" then
					state.skipped = state.skipped + 1
					vim.cmd("bdelete")
					vim.schedule(step)
				else
					vim.cmd("bdelete")
					state.stopped = true
					finish()
				end
			end)
		end

		step()
	end

	vim.ui.input({ prompt = "Substitute pattern > " }, function(pattern)
		if pattern == nil or pattern == "" then
			return
		end

		vim.ui.input({ prompt = "Replace with > " }, function(replacement)
			if replacement == nil then
				return
			end

			vim.ui.input({ prompt = "Flags [g] > ", default = "g" }, function(flags)
				if flags == nil then
					return
				end
				if flags == "" then
					flags = "g"
				end

				local escaped_pattern = vim.fn.escape(pattern, "/\\")
				local escaped_replacement = vim.fn.escape(replacement, "/\\")
				local substitute = string.format("%%s/%s/%s/%s", escaped_pattern, escaped_replacement, flags)
				run_files(substitute)
			end)
		end)
	end)
end

return M
