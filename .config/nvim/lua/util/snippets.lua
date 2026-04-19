local M = {}

local notify = require("util.notify")
local scratch = require("util.scratch")

local state = {
	configured = false,
	registered_project_dirs = {},
}

local function config_dir()
	return vim.fs.joinpath(vim.fn.stdpath("config"), "luasnippets")
end

local function vscode_dir()
	return vim.fs.joinpath(vim.fn.stdpath("config"), "snippets")
end

local function project_dir()
	return vim.fs.joinpath(vim.fn.getcwd(), ".luasnippets")
end

local function ensure_dir(path)
	vim.fn.mkdir(path, "p")
end

local function exists(path)
	return vim.uv.fs_stat(path) ~= nil
end

local function normalize_ft(ft)
	ft = ft or ""
	if ft == "" then
		ft = vim.bo.filetype
	end
	if ft == "" then
		ft = "all"
	end
	return ft
end

local function snippet_path(ft, use_project)
	local base = use_project and project_dir() or config_dir()
	return vim.fs.joinpath(base, ft .. ".lua")
end

local function template_lines(ft, use_project)
	local scope = use_project and "Project-local" or "Global"
	return {
		"local ls = require(\"luasnip\")",
		"local s = ls.snippet",
		"local t = ls.text_node",
		"local i = ls.insert_node",
		"",
		("-- %s snippets for `%s`"):format(scope, ft),
		"-- Save this file to hot-reload it in the current Neovim instance.",
		"",
		"return {",
		"  s(\"todo\", {",
		"    t(\"TODO: \"),",
		"    i(0),",
		"  }),",
		"}",
	}
end

local function create_template(path, ft, use_project)
	if exists(path) then
		return
	end
	ensure_dir(vim.fs.dirname(path))
	vim.fn.writefile(template_lines(ft, use_project), path)
end

local function load_user_collections()
	local lua_ok, lua_loader = pcall(require, "luasnip.loaders.from_lua")
	if not lua_ok then
		notify.error("Snippets", "LuaSnip lua-loader is unavailable")
		return false
	end

	ensure_dir(config_dir())
	lua_loader.load({
		paths = { config_dir() },
		fs_event_providers = { libuv = true },
	})

	local cwd_collection = project_dir()
	if not state.registered_project_dirs[cwd_collection] then
		lua_loader.load({
			lazy_paths = { cwd_collection },
			fs_event_providers = { libuv = true },
		})
		state.registered_project_dirs[cwd_collection] = true
	end

	return true
end

local function cmd_arg_to_ft(arg)
	return normalize_ft(vim.trim(arg or ""))
end

local function complete_filetypes(arg_lead)
	return vim.fn.getcompletion(arg_lead, "filetype")
end

function M.edit(ft, opts)
	opts = opts or {}
	ft = normalize_ft(ft)

	local path = snippet_path(ft, opts.project)
	create_template(path, ft, opts.project)
	vim.cmd.edit(vim.fn.fnameescape(path))
end

function M.reload()
	if not load_user_collections() then
		return
	end
	local vscode_ok, vscode = pcall(require, "luasnip.loaders.from_vscode")
	if vscode_ok then
		vscode.lazy_load({ paths = { vscode_dir() } })
	end
	notify.info("Snippets", "Reloaded global and project snippet collections")
end

function M.remove(ft, opts)
	opts = opts or {}
	ft = normalize_ft(ft)

	local path = snippet_path(ft, opts.project)
	if not exists(path) then
		notify.info("Snippets", "No snippet file at " .. path)
		return
	end

	local choice = vim.fn.confirm("Delete snippet file?\n" .. path, "&Delete\n&Cancel", 2)
	if choice ~= 1 then
		return
	end

	local ok, err = pcall(vim.fn.delete, path)
	if not ok or err ~= 0 then
		notify.error("Snippets", "Failed to delete " .. path)
		return
	end

	M.reload()
	notify.info("Snippets", "Removed " .. path)
end

function M.open_help()
	local lines = {
		"# Snippets",
		"",
		"Paths",
		("- Scissors / VS Code snippets: `%s/*.json`"):format(vscode_dir()),
		("- Global LuaSnip Lua snippets: `%s/*.lua`"):format(config_dir()),
		("- Project LuaSnip Lua snippets: `%s/*.lua`"):format(project_dir()),
		"- `all.lua` applies to every filetype for Lua snippets.",
		"",
		"Keys",
		"- `<leader>csh`: open this help",
		"- `<leader>csa`: add a new snippet with Scissors",
		"- `<leader>cse`: edit an existing Scissors snippet",
		"- `<leader>csl`: edit global Lua snippets for the current filetype",
		"- `<leader>csL`: edit project Lua snippets for the current filetype",
		"- `<leader>csg`: edit global Lua `all.lua` snippets",
		"- `<leader>csG`: edit project Lua `all.lua` snippets",
		"- `<leader>csr`: reload snippet collections",
		"- `<leader>csd`: delete global Lua snippets for the current filetype",
		"- `<leader>csD`: delete project Lua snippets for the current filetype",
		"",
		"Commands",
		"- `:ScissorsAddNewSnippet`: add a snippet in the VS Code JSON collection",
		"- `:ScissorsEditSnippet`: edit snippets with a picker",
		"- `:SnippetEdit[!] [ft]`: edit a filetype snippet file, `!` means project-local",
		"- `:SnippetAll[!]`: edit `all.lua`, `!` means project-local",
		"- `:SnippetReload`: reload snippet collections",
		"- `:SnippetRemove[!] [ft]`: delete a snippet file, `!` means project-local",
		"",
		"Triggering",
		"- Type a snippet trigger in Insert mode.",
		"- Press `<C-space>` if the Blink menu is not already open.",
		"- Pick the snippet completion item and accept it with `<CR>`.",
		"- Use `<Tab>` and `<S-Tab>` to jump through placeholders.",
		"- Use `<C-e>` to cycle a snippet choice node when one is active.",
		"",
		"Updating",
		"- For most snippets, use Scissors to add/edit them and save the JSON file it opens.",
		"- Save a snippet file to let LuaSnip hot-reload it in this Neovim instance.",
		"- `:SnippetReload` is the manual fallback if you want to force a refresh.",
		"",
		"Removing",
		"- Delete the snippet file with `:SnippetRemove` or the keymaps above.",
		"- If a deleted snippet still shows up in an old completion session, reopen the buffer or restart Neovim.",
		"",
		"Example",
		"```lua",
		"local ls = require(\"luasnip\")",
		"local s = ls.snippet",
		"local t = ls.text_node",
		"local i = ls.insert_node",
		"",
		"return {",
		"  s(\"fn\", {",
		"    t(\"function \"),",
		"    i(1, \"name\"),",
		"    t(\"()\"),",
		"    t({ \"\", \"  \" }),",
		"    i(0),",
		"    t({ \"\", \"end\" }),",
		"  }),",
		"}",
		"```",
	}

	scratch.open({
		title = "Snippets",
		lines = lines,
		filetype = "markdown",
		reuse = true,
		wrap = true,
		linebreak = true,
	})
end

function M.setup()
	if state.configured then
		return
	end
	state.configured = true

	local ok, ls = pcall(require, "luasnip")
	if not ok then
		notify.error("Snippets", "Failed to load LuaSnip")
		return
	end

	ls.config.set_config({
		history = true,
		updateevents = "TextChanged,TextChangedI",
		delete_check_events = "TextChanged,InsertLeave",
		enable_autosnippets = true,
	})

	local vscode_ok, vscode = pcall(require, "luasnip.loaders.from_vscode")
	if vscode_ok then
		ensure_dir(vscode_dir())
		local package_path = vim.fs.joinpath(vscode_dir(), "package.json")
		if not exists(package_path) then
			vim.fn.writefile({
				"{",
				'  "name": "nvim-next-snippets",',
				'  "contributes": {',
				'    "snippets": []',
				"  }",
				"}",
			}, package_path)
		end
		vscode.lazy_load({ paths = { vscode_dir() } })
	end

	load_user_collections()

	vim.api.nvim_create_autocmd("DirChanged", {
		callback = function()
			load_user_collections()
		end,
	})

	local map = require("util.map")
	map.n("<leader>csh", M.open_help, "Snippet help")
	map.n("<leader>csl", function()
		M.edit(nil, { project = false })
	end, "Snippet Lua edit filetype")
	map.n("<leader>csL", function()
		M.edit(nil, { project = true })
	end, "Snippet Lua edit project filetype")
	map.n("<leader>csg", function()
		M.edit("all", { project = false })
	end, "Snippet Lua edit all")
	map.n("<leader>csG", function()
		M.edit("all", { project = true })
	end, "Snippet Lua edit project all")
	map.n("<leader>csr", M.reload, "Snippet reload")
	map.n("<leader>csd", function()
		M.remove(nil, { project = false })
	end, "Snippet Lua delete filetype")
	map.n("<leader>csD", function()
		M.remove(nil, { project = true })
	end, "Snippet Lua delete project filetype")

	vim.keymap.set({ "i", "s" }, "<C-e>", function()
		if ls.choice_active() then
			ls.change_choice(1)
			return ""
		end
		return "<C-e>"
	end, {
		expr = true,
		silent = true,
		desc = "Snippet next choice",
	})

	vim.api.nvim_create_user_command("SnippetHelp", M.open_help, { desc = "Snippet help" })
	vim.api.nvim_create_user_command("SnippetReload", M.reload, { desc = "Reload snippet collections" })
	vim.api.nvim_create_user_command("SnippetEdit", function(ctx)
		M.edit(cmd_arg_to_ft(ctx.args), { project = ctx.bang })
	end, {
		bang = true,
		nargs = "?",
		complete = complete_filetypes,
		desc = "Edit snippet file for a filetype (! for project-local)",
	})
	vim.api.nvim_create_user_command("SnippetAll", function(ctx)
		M.edit("all", { project = ctx.bang })
	end, {
		bang = true,
		desc = "Edit all.lua snippet file (! for project-local)",
	})
	vim.api.nvim_create_user_command("SnippetRemove", function(ctx)
		M.remove(cmd_arg_to_ft(ctx.args), { project = ctx.bang })
	end, {
		bang = true,
		nargs = "?",
		complete = complete_filetypes,
		desc = "Delete snippet file for a filetype (! for project-local)",
	})
end

return M
