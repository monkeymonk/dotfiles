-- lua/util/pack/ui.lua
local M = {}

local api = vim.api
local ns = api.nvim_create_namespace("pack_ui")
local notify = require("util.notify")

local state = {
	bufnr = nil,
	winid = nil,
	win_autocmd_id = nil,
	pack_autocmd_id = nil,
	line_to_plugin = {},
	plugin_lines = {},
	expanded = {},
	show_help = false,
	show_log = false,
	update_cache = {},
	checking_updates = false,
	updating = false,
	update_status = {},
}

local function info(message)
	notify.info("Pack", message)
end

local function warn(message)
	notify.warn("Pack", message)
end

local function error(message)
	notify.error("Pack", message)
end

local function setup_highlights()
	local links = {
		PackHeader = "Title",
		PackButton = "Function",
		PackLoaded = "String",
		PackPending = "Comment",
		PackDisabled = "DiagnosticWarn",
		PackUpdate = "DiagnosticInfo",
		PackUpToDate = "DiagnosticOk",
		PackUpdating = "DiagnosticWarn",
		PackUpdated = "DiagnosticOk",
		PackUpdateFailed = "DiagnosticError",
		PackVersion = "Number",
		PackSection = "Label",
		PackSeparator = "FloatBorder",
		PackDetail = "Comment",
		PackHelp = "SpecialComment",
	}
	for group, target in pairs(links) do
		api.nvim_set_hl(0, group, { link = target, default = true })
	end
end

local function get_pack_data()
	local ok, plugins = pcall(vim.pack.get, nil, { info = false })
	if not ok then
		return {}
	end
	local by_src = {}
	for _, p in ipairs(plugins) do
		if p.spec.src then
			by_src[p.spec.src] = p
		end
	end
	return by_src
end

local function get_version_display(pack_info)
	if not pack_info then
		return ""
	end
	if pack_info.path then
		local result = vim.fn.system(
			"git -C " .. vim.fn.shellescape(pack_info.path) .. " describe --tags --exact-match HEAD 2>/dev/null"
		)
		if vim.v.shell_error == 0 then
			return vim.trim(result)
		end
	end
	if pack_info.rev then
		return pack_info.rev:sub(1, 7)
	end
	return ""
end

local function get_lazy_info(spec)
	if #spec.event > 0 then
		return "event: " .. table.concat(spec.event, ", ")
	elseif #spec.ft > 0 then
		return "ft: " .. table.concat(spec.ft, ", ")
	elseif #spec.cmd > 0 then
		return "cmd: " .. table.concat(spec.cmd, ", ")
	elseif spec.lazy then
		return "UIEnter"
	end
	return ""
end

local function build_content()
	if state.show_log then
		local lines = {}
		local hls = {}
		local log_path = vim.fs.joinpath(vim.fn.stdpath("log"), "nvim-pack.log")
		local log_lines = {}

		if vim.uv.fs_stat(log_path) then
			log_lines = vim.fn.readfile(log_path)
		end

		local function add(text, hl)
			local lnum = #lines
			lines[#lines + 1] = text
			if hl then
				hls[#hls + 1] = { lnum, 0, #text, hl }
			end
		end

		local header = string.format(" Pack Log -- %s", vim.fn.fnamemodify(log_path, ":~"))
		add(header, "PackHeader")

		local win_width = state.winid and api.nvim_win_get_width(state.winid) or 80
		add(" " .. string.rep("\u{2500}", win_width - 1), "PackSeparator")

		local bar = " [L] Plugins  [q] Close"
		add(bar)
		local lnum = #lines - 1
		for s, e in bar:gmatch("()%[.-%]()") do
			hls[#hls + 1] = { lnum, s - 1, e - 1, "PackButton" }
		end

		add("")
		if #log_lines == 0 then
			add(" No pack log available yet.", "PackDetail")
		else
			for _, line in ipairs(log_lines) do
				add(line)
			end
		end

		state.line_to_plugin = {}
		state.plugin_lines = {}
		return lines, hls
	end

	local pack_mod = require("util.pack")
	local spec_mod = require("util.pack.spec")
	local specs, disabled = pack_mod.get_specs()
	local pack_data = get_pack_data()

	local loaded = {}
	local pending = {}

	for _, spec in ipairs(specs) do
		if spec._loaded then
			loaded[#loaded + 1] = spec
		else
			pending[#pending + 1] = spec
		end
	end

	table.sort(loaded, function(a, b) return a.name < b.name end)
	table.sort(pending, function(a, b) return a.name < b.name end)
	table.sort(disabled, function(a, b) return a.name < b.name end)

	local lines = {}
	local hls = {}
	local line_to_plugin = {}
	local plugin_lines = {}

	local function add(text, hl)
		local lnum = #lines
		lines[#lines + 1] = text
		if hl then
			hls[#hls + 1] = { lnum, 0, #text, hl }
		end
	end

	local function add_hl(lnum, col_start, col_end, hl)
		hls[#hls + 1] = { lnum, col_start, col_end, hl }
	end

	-- Header
	local header = string.format(
		" Pack -- %d plugins | %d loaded | %d pending",
		#specs + #disabled, #loaded, #pending
	)
	add(header, "PackHeader")

	-- Separator
	local win_width = state.winid and api.nvim_win_get_width(state.winid) or 80
	add(" " .. string.rep("\u{2500}", win_width - 1), "PackSeparator")

	-- Action bar
	local check_label = state.checking_updates and "[S] Checking..." or "[S] Check"
	local update_label = state.updating and "[U] Updating..." or "[U]pdate All"
	local log_label = state.show_log and "[L] Plugins" or "[L] Log"
	local bar = string.format(" %s  [u] Update  %s  [X] Clean  [d] Delete  %s  [?] Help", update_label, check_label, log_label)
	add(bar)
	local lnum = #lines - 1
	for s, e in bar:gmatch("()%[.-%]()") do
		add_hl(lnum, s - 1, e - 1, "PackButton")
	end

	-- Help section
	if state.show_help then
		add("")
		add(" Keymaps:", "PackHelp")
		add("   U       Update all plugins", "PackHelp")
		add("   u       Update plugin under cursor", "PackHelp")
		add("   S       Check all plugins for updates", "PackHelp")
		add("   X       Clean non-active plugins", "PackHelp")
		add("   d       Delete plugin under cursor from disk (non-active only)", "PackHelp")
		add("   L       Toggle pack log in this window", "PackHelp")
		add("   <CR>    Toggle plugin details", "PackHelp")
		add("   ]]      Jump to next plugin", "PackHelp")
		add("   [[      Jump to previous plugin", "PackHelp")
		add("   q/Esc   Close window", "PackHelp")
	end

	-- Compute max name width
	local max_name = 0
	for _, t in ipairs({ loaded, pending, disabled }) do
		for _, spec in ipairs(t) do
			max_name = math.max(max_name, #spec.name)
		end
	end

	local function render_plugin(spec, icon, hl_group)
		local name = spec.name
		local pad = string.rep(" ", max_name - #name + 2)
		local pdata = spec.src and pack_data[spec.src] or nil
		local version = get_version_display(pdata)

		-- Update check indicator
		local update_icon = ""
		local update_text = nil
		local update_hl = nil
		local cached = state.update_cache[name]
		local status = state.update_status[name]
		if cached then
			if cached.available then
				update_icon = " \u{2191}"
			else
				update_icon = " \u{2713}"
			end
		end
		if status then
			if status.kind == "queued" then
				update_text = " updating..."
				update_hl = "PackUpdating"
			elseif status.kind == "updating" then
				update_text = " updating..."
				update_hl = "PackUpdating"
			elseif status.kind == "updated" then
				update_text = " updated"
				update_hl = "PackUpdated"
			elseif status.kind == "failed" then
				update_text = " failed"
				update_hl = "PackUpdateFailed"
			end
		end

		-- Lazy info for pending plugins
		local lazy_info = ""
		if not spec._loaded and spec_mod.is_lazy(spec) then
			lazy_info = get_lazy_info(spec)
		end

		local right = version
		if lazy_info ~= "" then
			right = lazy_info
		end

		local line = string.format("   %s %s%s%s%s", icon, name, pad, update_icon, right)
		local lnum_cur = #lines
		add(line)

		-- Highlights
		local icon_bytes = #icon
		local icon_start = 3
		local name_start = icon_start + icon_bytes + 1
		add_hl(lnum_cur, icon_start, icon_start + icon_bytes, hl_group)
		add_hl(lnum_cur, name_start, name_start + #name, hl_group)

		if update_icon ~= "" then
			local ui_start = name_start + #name + #pad
			local ui_hl = cached and cached.available and "PackUpdate" or "PackUpToDate"
			add_hl(lnum_cur, ui_start, ui_start + #update_icon, ui_hl)
		end

		if #right > 0 and lazy_info == "" then
			local ver_start = name_start + #name + #pad + #update_icon
			add_hl(lnum_cur, ver_start, ver_start + #right, "PackVersion")
		end
		if update_text then
			local status_start = #line
			line = line .. update_text
			lines[#lines] = line
			add_hl(lnum_cur, status_start, status_start + #update_text, update_hl)
		end

		line_to_plugin[lnum_cur + 1] = name
		plugin_lines[name] = lnum_cur + 1

		-- Expanded details
		if state.expanded[name] then
			local details = {}
			if pdata and pdata.path then
				details[#details + 1] = string.format("     Path:    %s", pdata.path)
			end
			if spec.src then
				details[#details + 1] = string.format("     Source:  %s", spec.src)
			end
			if pdata and pdata.rev then
				details[#details + 1] = string.format("     Rev:     %s", pdata.rev)
			end
			if spec.dependencies and #spec.dependencies > 0 then
				local deps = {}
				for _, d in ipairs(spec.dependencies) do
					deps[#deps + 1] = d:match("([^/]+/[^/]+)$") or d
				end
				details[#details + 1] = string.format("     Deps:    %s", table.concat(deps, ", "))
			end
			if cached and cached.available and cached.new_rev then
				details[#details + 1] = string.format("     Update:  %s -> %s", version, cached.new_rev)
			end
			for _, d in ipairs(details) do
				add(d, "PackDetail")
			end
		end
	end

	-- Loaded section
	add("")
	add(string.format(" Loaded (%d)", #loaded), "PackSection")
	for _, spec in ipairs(loaded) do
		render_plugin(spec, "\u{25CF}", "PackLoaded")
	end

	-- Pending section
	if #pending > 0 then
		add("")
		add(string.format(" Not Loaded (%d)", #pending), "PackSection")
		for _, spec in ipairs(pending) do
			render_plugin(spec, "\u{25CB}", "PackPending")
		end
	end

	-- Disabled section
	if #disabled > 0 then
		add("")
		add(string.format(" Disabled (%d)", #disabled), "PackSection")
		for _, spec in ipairs(disabled) do
			render_plugin(spec, "\u{2717}", "PackDisabled")
		end
	end

	state.line_to_plugin = line_to_plugin
	state.plugin_lines = plugin_lines

	return lines, hls
end

local function render()
	if not state.bufnr or not api.nvim_buf_is_valid(state.bufnr) then
		return
	end

	local lines, hls = build_content()

	vim.bo[state.bufnr].modifiable = true
	api.nvim_buf_set_lines(state.bufnr, 0, -1, false, lines)
	vim.bo[state.bufnr].modifiable = false
	vim.bo[state.bufnr].modified = false

	api.nvim_buf_clear_namespace(state.bufnr, ns, 0, -1)
	for _, hl in ipairs(hls) do
		api.nvim_buf_set_extmark(state.bufnr, ns, hl[1], hl[2], {
			end_col = hl[3],
			hl_group = hl[4],
		})
	end
end

local function plugin_at_cursor()
	if not state.winid or not api.nvim_win_is_valid(state.winid) then
		return nil
	end
	local row = api.nvim_win_get_cursor(state.winid)[1]
	return state.line_to_plugin[row]
end

local function close()
	if state.win_autocmd_id then
		pcall(api.nvim_del_autocmd, state.win_autocmd_id)
		state.win_autocmd_id = nil
	end
	if state.pack_autocmd_id then
		pcall(api.nvim_del_autocmd, state.pack_autocmd_id)
		state.pack_autocmd_id = nil
	end
	if state.winid and api.nvim_win_is_valid(state.winid) then
		api.nvim_win_close(state.winid, true)
	end
	state.winid = nil
	state.bufnr = nil
	state.expanded = {}
	state.show_help = false
	state.show_log = false
end

local function jump_plugin(direction)
	if not state.winid or not api.nvim_win_is_valid(state.winid) then
		return
	end
	local row = api.nvim_win_get_cursor(state.winid)[1]
	local plines = {}
	for lnum, _ in pairs(state.line_to_plugin) do
		plines[#plines + 1] = lnum
	end
	table.sort(plines)

	if direction > 0 then
		for _, lnum in ipairs(plines) do
			if lnum > row then
				api.nvim_win_set_cursor(state.winid, { lnum, 0 })
				return
			end
		end
		if #plines > 0 then
			api.nvim_win_set_cursor(state.winid, { plines[1], 0 })
		end
	else
		for i = #plines, 1, -1 do
			if plines[i] < row then
				api.nvim_win_set_cursor(state.winid, { plines[i], 0 })
				return
			end
		end
		if #plines > 0 then
			api.nvim_win_set_cursor(state.winid, { plines[#plines], 0 })
		end
	end
end

local function check_updates()
	if state.checking_updates then
		info("Update check already running")
		return
	end

	local pack_mod = require("util.pack")
	local specs = pack_mod.get_specs()
	local pack_data = get_pack_data()
	local pending = 0
	local completed = 0
	local failures = 0
	local available = 0

	local function resolve_remote_ref(path, callback)
		local refs_to_try = { "@{upstream}" }

		local function try_ref(index)
			local ref = refs_to_try[index]
			if not ref then
				callback(nil, nil)
				return
			end

			vim.system(
				{ "git", "-C", path, "rev-list", ("HEAD..%s"):format(ref), "--count" },
				{ text = true },
				function(result)
					if result.code == 0 then
						callback(ref, tonumber(vim.trim(result.stdout)) or 0)
					else
						try_ref(index + 1)
					end
				end
			)
		end

		vim.system(
			{ "git", "-C", path, "symbolic-ref", "--quiet", "--short", "refs/remotes/origin/HEAD" },
			{ text = true },
			function(origin_head)
				if origin_head.code == 0 then
					refs_to_try[#refs_to_try + 1] = vim.trim(origin_head.stdout)
					refs_to_try[#refs_to_try + 1] = "origin/HEAD"
				end
				try_ref(1)
			end
		)
	end

	local function resolve_short_rev(path, ref, callback)
		vim.system(
			{ "git", "-C", path, "rev-parse", "--short", ref },
			{ text = true },
			function(result)
				if result.code == 0 then
					callback(vim.trim(result.stdout))
				else
					callback(nil)
				end
			end
		)
	end

	state.checking_updates = true
	state.update_cache = {}
	render()
	info("Checking for plugin updates...")

	local function finish()
		completed = completed + 1
		if completed < pending then
			return
		end

		state.checking_updates = false
		render()

		local message = string.format("Checked %d plugin(s), %d update(s), %d failure(s)", pending, available, failures)
		if failures > 0 then
			warn(message)
		else
			info(message)
		end
	end

	for _, spec in ipairs(specs) do
		local pdata = spec.src and pack_data[spec.src] or nil
		if not pdata or not pdata.path then
		else
			pending = pending + 1

			local path = pdata.path
			vim.system(
				{ "git", "-C", path, "fetch" },
				{},
				function(fetch_result)
					if fetch_result.code ~= 0 then
						failures = failures + 1
						state.update_cache[spec.name] = {
							available = false,
							error = "fetch failed",
						}
						vim.schedule(function()
							render()
							finish()
						end)
						return
					end
					vim.system(
						{ "git", "-C", path, "rev-parse", "--git-dir" },
						{ text = true },
						function(count_result)
							if count_result.code ~= 0 then
								failures = failures + 1
								state.update_cache[spec.name] = {
									available = false,
									error = "git error",
								}
								vim.schedule(function()
									render()
									finish()
								end)
								return
							end

							resolve_remote_ref(path, function(ref, count)
								if not ref or count == nil then
									failures = failures + 1
									state.update_cache[spec.name] = {
										available = false,
										error = "no remote ref",
									}
									vim.schedule(function()
										render()
										finish()
									end)
									return
								end

								if count > 0 then
									available = available + 1
									resolve_short_rev(path, ref, function(new_rev)
										state.update_cache[spec.name] = {
											available = true,
											new_rev = new_rev,
										}
										vim.schedule(function()
											render()
											finish()
										end)
									end)
									return
								end

								state.update_cache[spec.name] = {
									available = false,
									new_rev = nil,
								}
								vim.schedule(function()
									render()
									finish()
								end)
							end)
						end
					)
				end
			)
		end
	end

	if pending == 0 then
		state.checking_updates = false
		render()
		info("No installed plugins to check")
	end
end

local function collect_update_targets(single_name)
	local pack_mod = require("util.pack")
	local specs = pack_mod.get_specs()
	local pack_data = get_pack_data()
	local targets = {}

	for _, spec in ipairs(specs) do
		if single_name == nil or spec.name == single_name then
			local cached = state.update_cache[spec.name]
			local pdata = spec.src and pack_data[spec.src] or nil
			if cached and cached.available and pdata and pdata.spec and pdata.spec.name then
				targets[#targets + 1] = {
					display_name = spec.name,
					pack_name = pdata.spec.name,
					src = spec.src,
				}
			end
		end
	end

	table.sort(targets, function(a, b)
		return a.display_name < b.display_name
	end)
	return targets
end

local function start_update(names)
	if state.updating then
		info("Update already running")
		return
	end

	if not names or #names == 0 then
		info("No checked updates to apply. Run S first.")
		return
	end

	local pack_data = get_pack_data()
	state.updating = true
	state.update_status = {}

	local pack_names = {}
	for _, item in ipairs(names) do
		pack_names[#pack_names + 1] = item.pack_name
		local pdata = item.src and pack_data[item.src] or nil
		state.update_status[item.display_name] = {
			kind = "queued",
			src = item.src,
			pack_name = item.pack_name,
			before_rev = pdata and pdata.rev or nil,
		}
	end

	render()
	info(string.format("Updating %d plugin(s)...", #pack_names))

	vim.schedule(function()
		local ok, err = pcall(vim.pack.update, pack_names, { force = true })
		local fresh_pack_data = get_pack_data()
		local updated = 0
		local failed = 0

		for _, item in ipairs(names) do
			local status = state.update_status[item.display_name]
			if status then
				local pdata = status.src and fresh_pack_data[status.src] or nil
				local after_rev = pdata and pdata.rev or nil
				if status.kind == "updated" or (after_rev and status.before_rev and after_rev ~= status.before_rev) then
					status.kind = "updated"
					updated = updated + 1
					state.update_cache[item.display_name] = { available = false, new_rev = nil }
				else
					status.kind = "failed"
					failed = failed + 1
				end
			end
		end

		state.updating = false
		render()

		if not ok then
			error("Update failed\n" .. tostring(err))
			return
		end

		local message = string.format("Updated %d plugin(s), %d failed", updated, failed)
		if failed > 0 then
			warn(message)
		else
			info(message)
		end
	end)
end

local function setup_keymaps()
	local buf = state.bufnr
	local opts = { buffer = buf, silent = true, nowait = true }

	vim.keymap.set("n", "q", close, opts)
	vim.keymap.set("n", "<Esc>", close, opts)

	vim.keymap.set("n", "U", function()
		start_update(collect_update_targets())
	end, opts)

	vim.keymap.set("n", "u", function()
		local name = plugin_at_cursor()
		if not name then
			return
		end
		start_update(collect_update_targets(name))
	end, opts)

	vim.keymap.set("n", "S", function()
		check_updates()
	end, opts)

	vim.keymap.set("n", "X", function()
		local to_clean = {}
		local pd = get_pack_data()
		for _, pdata in pairs(pd) do
			if not pdata.active then
				to_clean[#to_clean + 1] = pdata.spec.name
			end
		end

		if #to_clean == 0 then
			info("Nothing to clean")
			return
		end

		table.sort(to_clean)
		local msg = string.format("Remove %d non-active plugin(s)?\n\n%s", #to_clean, table.concat(to_clean, "\n"))
		local choice = vim.fn.confirm(msg, "&Yes\n&No", 2, "Question")
		if choice == 1 then
			close()
			local ok, err = pcall(vim.pack.del, to_clean)
			if ok then
				info(string.format("Removed %d plugin(s)", #to_clean))
			else
				error(tostring(err))
			end
		end
	end, opts)

	vim.keymap.set("n", "d", function()
		local name = plugin_at_cursor()
		if not name then
			return
		end
		local pack_mod = require("util.pack")
		local specs = pack_mod.get_specs()
		local pd = get_pack_data()
		local pdata
		for _, sp in ipairs(specs) do
			if sp.name == name and sp.src then
				pdata = pd[sp.src]
				break
			end
		end
		if not pdata then
			warn(string.format("%s is not installed", name))
			return
		end
		if pdata.active then
			warn(string.format("%s is active, remove from config first", name))
			return
		end
		local pack_name = pdata.spec.name
		local choice = vim.fn.confirm(string.format("Delete plugin %s?", name), "&Yes\n&No", 2, "Question")
		if choice == 1 then
			close()
			local ok, err = pcall(vim.pack.del, { pack_name })
			if ok then
				info(string.format("Removed %s", name))
			else
				error(tostring(err))
			end
		end
	end, opts)

	vim.keymap.set("n", "L", function()
		state.show_log = not state.show_log
		render()
	end, opts)

	vim.keymap.set("n", "<CR>", function()
		local name = plugin_at_cursor()
		if name then
			state.expanded[name] = not state.expanded[name]
			render()
			if state.plugin_lines[name] then
				api.nvim_win_set_cursor(state.winid, { state.plugin_lines[name], 0 })
			end
		end
	end, opts)

	vim.keymap.set("n", "]]", function() jump_plugin(1) end, opts)
	vim.keymap.set("n", "[[", function() jump_plugin(-1) end, opts)

	vim.keymap.set("n", "?", function()
		state.show_help = not state.show_help
		render()
	end, opts)
end

function M.open()
	if state.winid and api.nvim_win_is_valid(state.winid) then
		api.nvim_set_current_win(state.winid)
		return
	end

	setup_highlights()

	state.bufnr = api.nvim_create_buf(false, true)
	vim.bo[state.bufnr].buftype = "nofile"
	vim.bo[state.bufnr].bufhidden = "wipe"
	vim.bo[state.bufnr].swapfile = false
	vim.bo[state.bufnr].filetype = "pack-ui"

	local cols = vim.o.columns
	local rows = vim.o.lines
	local width = math.min(cols - 4, math.max(math.floor(cols * 0.8), 60))
	local height = math.min(rows - 4, math.max(math.floor(rows * 0.7), 20))
	local row = math.floor((rows - height) / 2)
	local col = math.floor((cols - width) / 2)

	state.winid = api.nvim_open_win(state.bufnr, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		title = " Pack ",
		title_pos = "center",
	})

	vim.wo[state.winid].cursorline = true
	vim.wo[state.winid].wrap = false

	render()
	setup_keymaps()

	state.pack_autocmd_id = api.nvim_create_autocmd({ "PackChangedPre", "PackChanged" }, {
		callback = function(ev)
			if not ev or not ev.data or ev.data.kind ~= "update" or not ev.data.spec then
				return
			end

			local status = state.update_status[ev.data.spec.name]
			if not status then
				return
			end

			status.kind = ev.event == "PackChangedPre" and "updating" or "updated"
			vim.schedule(render)
		end,
	})

	local captured_winid = state.winid
	state.win_autocmd_id = api.nvim_create_autocmd("WinClosed", {
		buffer = state.bufnr,
		once = true,
		callback = function(ev)
			if vim._tointeger(ev.match) ~= captured_winid then
				return
			end
			state.winid = nil
			state.bufnr = nil
			state.win_autocmd_id = nil
			state.pack_autocmd_id = nil
			state.expanded = {}
			state.show_help = false
			state.show_log = false
		end,
	})
end

return M
