local M = {}

local notify = require("util.notify")
local scratch = require("util.scratch")

local state = { configured = false }

local mode_labels = {
	n = "Normal",
	x = "Visual",
	v = "Visual",
	i = "Insert",
	t = "Terminal",
	o = "Operator-pending",
}

local function add(lines, line)
	lines[#lines + 1] = line
end

local function blank(lines)
	add(lines, "")
end

local function normalize_lhs(lhs)
	local localleader = vim.g.maplocalleader or "\\"
	local leader = vim.g.mapleader or "\\"

	local function replace_prefix(prefix, label)
		if prefix ~= "" and lhs:sub(1, #prefix) == prefix then
			return label .. lhs:sub(#prefix + 1)
		end
	end

	lhs = replace_prefix(localleader, "<localleader>") or replace_prefix(leader, "<leader>") or lhs
	return lhs:gsub(" ", "<space>")
end

local function load_group_specs()
	local ok, spec = pcall(require, "plugins.which-key")
	if not ok or type(spec) ~= "table" or type(spec.opts) ~= "table" or type(spec.opts.spec) ~= "table" then
		return {}
	end

	local groups = {}
	for _, item in ipairs(spec.opts.spec) do
		if type(item) == "table" and type(item[1]) == "string" and type(item.group) == "string" then
			groups[#groups + 1] = {
				prefix = item[1],
				title = item.group,
			}
		end
	end

	table.sort(groups, function(left, right)
		return #left.prefix > #right.prefix
	end)
	return groups
end

local function group_for(lhs, groups)
	for _, group in ipairs(groups) do
		if lhs == group.prefix or lhs:sub(1, #group.prefix) == group.prefix then
			return group.title, group.prefix
		end
	end

	if lhs:sub(1, 8) == "<leader>" then
		return "leader", "<leader>"
	end

	return mode_labels.n, ""
end

local function collect_keymaps()
	local groups = load_group_specs()
	local out = {}

	for _, mode in ipairs({ "n", "x", "i", "t" }) do
		for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
			if map.desc and map.desc ~= "" then
				local lhs = normalize_lhs(map.lhs)
				local title, prefix = group_for(lhs, groups)
				if mode ~= "n" and lhs:sub(1, 8) ~= "<leader>" then
					title = mode_labels[mode] or mode
					prefix = mode
				end

				local key = ("%s:%s"):format(prefix, title)
				out[key] = out[key]
					or {
						title = title,
						prefix = prefix,
						mode = mode,
						items = {},
					}
				out[key].items[#out[key].items + 1] = {
					lhs = lhs,
					desc = map.desc,
				}
			end
		end
	end

	local sections = vim.tbl_values(out)
	table.sort(sections, function(left, right)
		if left.prefix == right.prefix then
			return left.title < right.title
		end
		return left.prefix < right.prefix
	end)

	for _, section in ipairs(sections) do
		table.sort(section.items, function(left, right)
			return left.lhs < right.lhs
		end)
	end

	return sections
end

local function command_description(command)
	if type(command.definition) ~= "string" or command.definition == "" then
		return nil
	end

	if command.definition:match("^%s*lua%s+") or command.definition:match("^%s*call%s+") then
		return nil
	end

	return command.definition
end

local function collect_commands()
	local commands = {}
	for name, command in pairs(vim.api.nvim_get_commands({ builtin = false })) do
		local description = command_description(command)
		if description then
			commands[#commands + 1] = {
				name = name,
				description = description,
			}
		end
	end

	table.sort(commands, function(left, right)
		return left.name < right.name
	end)
	return commands
end

local function collect_plugins()
	local ok, api = pcall(require, "zpack.api")
	if not ok then
		return {}
	end

	local plugins = api.get_plugins()
	table.sort(plugins, function(left, right)
		return left.name < right.name
	end)
	return plugins
end

local function generated_lines()
	local lines = {
		"# Memory Sheet",
		"",
		"Generated from active keymaps, user commands, and zpack state. Update the source keymap `desc`, command `desc`, or plugin spec instead of this sheet.",
		"",
	}

	local keymaps = collect_keymaps()
	add(lines, "## Keymaps")
	blank(lines)
	for _, section in ipairs(keymaps) do
		add(lines, ("### %s"):format(section.title))
		blank(lines)
		for _, item in ipairs(section.items) do
			add(lines, ("- `%s` - %s"):format(item.lhs, item.desc))
		end
		blank(lines)
	end

	local commands = collect_commands()
	add(lines, "## Commands")
	blank(lines)
	if #commands == 0 then
		add(lines, "- No described user commands found.")
	else
		for _, command in ipairs(commands) do
			add(lines, ("- `:%s` - %s"):format(command.name, command.description))
		end
	end
	blank(lines)

	local plugins = collect_plugins()
	add(lines, "## Plugin state")
	blank(lines)
	if #plugins == 0 then
		add(lines, "- zpack state unavailable.")
	else
		local counts = {}
		for _, plugin in ipairs(plugins) do
			counts[plugin.status] = (counts[plugin.status] or 0) + 1
		end
		add(lines, ("- loaded: %d"):format(counts.loaded or 0))
		add(lines, ("- pending: %d"):format(counts.pending or 0))
		add(lines, ("- disabled: %d"):format(counts.disabled or 0))
		if counts.disabled and counts.disabled > 0 then
			blank(lines)
			add(lines, "### Disabled plugins")
			blank(lines)
			for _, plugin in ipairs(plugins) do
				if plugin.status == "disabled" then
					add(lines, ("- `%s` - %s"):format(plugin.name, plugin.src))
				end
			end
		end
	end
	blank(lines)

	add(lines, "## Memory Sheet buffer keys")
	blank(lines)
	add(lines, "- `]]` / `[[` - next / previous section")
	add(lines, "- `gs` - pick section")
	add(lines, "- `q` - close")

	return lines
end

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
	local buf = scratch.open({
		title = "Memory Sheet",
		lines = generated_lines(),
		filetype = "markdown",
		reuse = true,
		wrap = true,
		linebreak = true,
		cursorline = true,
	})
	set_keymaps(buf)
end

function M.setup()
	if state.configured then
		return
	end
	state.configured = true

	vim.api.nvim_create_user_command("MemorySheet", M.open, { desc = "Open memory sheet quick reference" })
end

return M
