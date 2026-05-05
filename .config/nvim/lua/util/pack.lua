-- Thin wrapper around vim.pack for plugin specs in lua/plugins/.
--
-- Spec format (table returned from each lua/plugins/*.lua file):
--   src        = "https://github.com/owner/repo"  (or position [1])
--   name       = "repo"                            (inferred from src tail)
--   version    = "v1.0" | { min = "v1.0" } | branch/tag/commit string
--   priority   = 50                                (eager order, higher first)
--   dependencies = { "https://..." }               (string URLs only)
--   event/ft/cmd = string | { ... }                (lazy-load triggers)
--   keys       = { { lhs, rhs?, mode?, desc? }, ... } | function(map, spec)
--   lazy       = true                              (force lazy with no trigger)
--   cond       = function() -> bool                (skip load if false)
--   enabled    = false                             (skip entirely)
--   build      = "<cmd>" | function(spec)          (run on PackChanged)
--   init       = function(spec)                    (always runs at startup)
--   setup      = function(spec)                    (runs on load)
--   opts       = table | function() -> table       (passed to require(main).setup)
--   main       = "module.name"                     (override inferred main module)
--   config     = function(spec, opts)              (custom load callback)
--   install    = { binaries, packages, notes }     (consumed by health check)

local M = {}

local notify = require("util.notify")

local state = {
	specs = {},
	disabled = {},
	by_name = {},
}

local function as_list(v)
	if v == nil then
		return {}
	end
	if type(v) == "string" then
		return { v }
	end
	return v
end

local function infer_name(src, fallback)
	if not src then
		return fallback
	end
	return (src:match("([^/]+)$") or src):gsub("%.git$", "")
end

local function infer_mains(name)
	local base = name:gsub("%.nvim$", ""):gsub("%.vim$", ""):gsub("%-nvim$", "")
	local candidates = { base }

	if base:match("^nvim%-") then
		candidates[#candidates + 1] = base:gsub("^nvim%-", "")
	end
	if base:match("%-") then
		candidates[#candidates + 1] = base:gsub("%-", ".")
	end
	candidates[#candidates + 1] = base:lower()

	local seen, unique = {}, {}
	for _, c in ipairs(candidates) do
		if not seen[c] then
			seen[c] = true
			unique[#unique + 1] = c
		end
	end
	return unique
end

local function require_main(spec)
	local names = spec.main and { spec.main } or infer_mains(spec.name)
	for _, name in ipairs(names) do
		local ok, mod = pcall(require, name)
		if ok and type(mod) == "table" and type(mod.setup) == "function" then
			return mod
		end
	end
	error(("Could not resolve main module for %s. Tried: %s. Set `main = \"...\"` on the spec.")
		:format(spec.name, table.concat(names, ", ")))
end

local function is_enabled(spec)
	if spec.enabled == nil then
		return true
	end
	if type(spec.enabled) == "function" then
		return spec.enabled() and true or false
	end
	return spec.enabled == true
end

local function has_lazy_keys(spec)
	-- Only a table of key mappings counts as a lazy-load trigger; the function
	-- form is just a callback that runs on load, so a spec whose only `keys`
	-- entry is a function should still be eager (matches the original loader).
	return type(spec.keys) == "table" and #spec.keys > 0
end

local function is_lazy(spec)
	return spec.lazy == true
		or #spec.event > 0
		or #spec.ft > 0
		or #spec.cmd > 0
		or has_lazy_keys(spec)
end

local function make_loader(spec)
	if spec.config then
		local cb = spec.config
		return function()
			local opts = type(spec.opts) == "function" and spec.opts() or (spec.opts or {})
			cb(spec, opts)
		end
	end
	if spec.setup then
		return spec.setup
	end
	if spec.opts ~= nil then
		return function()
			local opts = type(spec.opts) == "function" and spec.opts() or spec.opts
			require_main(spec).setup(opts or {})
		end
	end
	return nil
end

local function normalize(spec)
	spec.src = spec.src or spec[1]
	spec.name = spec.name or infer_name(spec.src, tostring(spec[1]))
	spec.priority = spec.priority or 50
	spec.event = as_list(spec.event)
	spec.ft = as_list(spec.ft)
	spec.cmd = as_list(spec.cmd)
	spec.dependencies = as_list(spec.dependencies)
	spec._loader = make_loader(spec)
	return spec
end

local function load_specs()
	local dir = vim.fn.stdpath("config") .. "/lua/plugins"
	local handle = vim.uv.fs_scandir(dir)
	if not handle then
		return
	end

	while true do
		local fname, ftype = vim.uv.fs_scandir_next(handle)
		if not fname then
			break
		end
		if ftype == "file" and fname:sub(-4) == ".lua" then
			local mod = "plugins." .. fname:sub(1, -5)
			local ok, spec = pcall(require, mod)
			if not ok then
				notify.error("pack", ("Failed to load %s\n%s"):format(mod, spec))
			elseif type(spec) == "table" and spec.src or spec[1] then
				spec = normalize(spec)
				if is_enabled(spec) then
					state.specs[#state.specs + 1] = spec
				else
					state.disabled[#state.disabled + 1] = spec
				end
				state.by_name[spec.name] = spec
			end
		end
	end
end

local function pack_sources()
	local seen, eager, lazy = {}, {}, {}

	local function push(src, version, lazy_flag)
		if not src or seen[src] then
			return
		end
		seen[src] = true
		local entry = { src = src }
		if version ~= nil then
			entry.version = version
		end
		if lazy_flag then
			lazy[#lazy + 1] = entry
		else
			eager[#eager + 1] = entry
		end
	end

	for _, spec in ipairs(state.specs) do
		push(spec.src, spec.version, is_lazy(spec))
		for _, dep in ipairs(spec.dependencies) do
			push(dep, nil, false)
		end
	end
	return eager, lazy
end

local function pack_name(spec)
	return spec.src and spec.src:match("([^/]+)$"):gsub("%.git$", "") or spec.name
end

local function load_plugin(spec)
	if spec._loaded then
		return
	end
	if spec.cond and not pcall(spec.cond) then
		return
	end
	if type(spec.cond) == "function" and not spec.cond() then
		return
	end

	spec._loaded = true

	if is_lazy(spec) then
		pcall(vim.cmd.packadd, pack_name(spec))
	end

	if spec._loader then
		local ok, err = pcall(spec._loader, spec)
		if not ok then
			notify.error("pack", ("Setup failed for %s\n%s"):format(spec.name, err))
		end
	end

	if type(spec.keys) == "function" then
		local ok, err = pcall(spec.keys, require("util.map"), spec)
		if not ok then
			notify.error("pack", ("Keys failed for %s\n%s"):format(spec.name, err))
		end
	elseif type(spec.keys) == "table" then
		local map = require("util.map")
		for _, k in ipairs(spec.keys) do
			if k[1] and k[2] then
				map.map(k.mode or "n", k[1], k[2], k.desc, {
					expr = k.expr,
					silent = k.silent,
					remap = k.remap,
					nowait = k.nowait,
				})
			end
		end
	end
end

local function feed(rhs)
	if type(rhs) == "function" then
		return rhs()
	end
	if type(rhs) == "string" then
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(rhs, true, true, true), "m", false)
	end
end

local function register_lazy_keys(spec)
	if type(spec.keys) == "function" then
		local map = require("util.map")
		local proxy = setmetatable({}, {
			__index = function(_, k)
				return function(lhs, rhs, desc, extra)
					map[k](lhs, function()
						load_plugin(spec)
						feed(rhs)
					end, desc, extra)
				end
			end,
		})
		proxy.map = function(mode, lhs, rhs, desc, extra)
			map.map(mode, lhs, function()
				load_plugin(spec)
				feed(rhs)
			end, desc, extra)
		end
		pcall(spec.keys, proxy, spec)
	elseif type(spec.keys) == "table" then
		local map = require("util.map")
		for _, k in ipairs(spec.keys) do
			if k[1] then
				local rhs = k[2]
				map.map(k.mode or "n", k[1], function()
					load_plugin(spec)
					if rhs then
						feed(rhs)
					end
				end, k.desc, { expr = k.expr, silent = k.silent, remap = k.remap, nowait = k.nowait })
			end
		end
	end
end

local function register_lazy_triggers(spec)
	register_lazy_keys(spec)

	local has_trigger = #spec.event > 0 or #spec.ft > 0 or #spec.cmd > 0

	if #spec.event > 0 then
		local group = vim.api.nvim_create_augroup("pack_event_" .. spec.name, { clear = true })
		for _, ev in ipairs(spec.event) do
			local event, pattern = ev:match("^(%S+)%s+(.+)$")
			vim.api.nvim_create_autocmd(event or ev, {
				group = group,
				pattern = pattern,
				once = true,
				callback = function()
					load_plugin(spec)
				end,
			})
		end
	end

	if #spec.ft > 0 then
		local group = vim.api.nvim_create_augroup("pack_ft_" .. spec.name, { clear = true })
		vim.api.nvim_create_autocmd("FileType", {
			group = group,
			pattern = spec.ft,
			once = true,
			callback = function(args)
				load_plugin(spec)
				vim.api.nvim_exec_autocmds("FileType", { buffer = args.buf })
			end,
		})
	end

	for _, cmd in ipairs(spec.cmd) do
		vim.api.nvim_create_user_command(cmd, function(ctx)
			vim.api.nvim_del_user_command(cmd)
			load_plugin(spec)
			vim.cmd(("%s%s %s"):format(cmd, ctx.bang and "!" or "", ctx.args))
		end, { nargs = "*", bang = true, complete = "file" })
	end

	-- Keys alone don't substitute for an explicit trigger; without one we
	-- still want the plugin to initialize at UIEnter (gitsigns, snacks,
	-- yanky and persistence rely on this for their startup hooks).
	if not has_trigger then
		vim.api.nvim_create_autocmd("UIEnter", {
			once = true,
			callback = function()
				vim.schedule(function()
					load_plugin(spec)
				end)
			end,
		})
	end
end

local function register_build_hooks()
	vim.api.nvim_create_autocmd("PackChanged", {
		callback = function(ev)
			local spec = state.by_name[ev.data.spec.name]
			if not spec or not spec.build or ev.data.kind == "delete" then
				return
			end
			if not ev.data.active then
				pcall(vim.cmd.packadd, pack_name(spec))
			end
			if type(spec.build) == "function" then
				pcall(spec.build, spec)
			elseif type(spec.build) == "string" then
				pcall(vim.cmd, spec.build)
			end
		end,
	})
end

local function run_inits()
	for _, spec in ipairs(state.specs) do
		if type(spec.init) == "function" then
			local ok, err = pcall(spec.init, spec)
			if not ok then
				notify.error("pack", ("Init failed for %s\n%s"):format(spec.name, err))
			end
		end
	end
end

function M.setup()
	if vim.fn.has("nvim-0.12") == 0 then
		notify.error("pack", "Requires Neovim >= 0.12")
		return
	end

	load_specs()
	register_build_hooks()

	local eager, lazy = pack_sources()
	if #eager > 0 then
		vim.pack.add(eager)
	end
	if #lazy > 0 then
		vim.pack.add(lazy, { load = function() end })
	end
end

function M.boot()
	run_inits()

	local eager, lazy = {}, {}
	for _, spec in ipairs(state.specs) do
		if is_lazy(spec) then
			lazy[#lazy + 1] = spec
		else
			eager[#eager + 1] = spec
		end
	end

	table.sort(eager, function(a, b)
		return a.priority > b.priority
	end)

	for _, spec in ipairs(eager) do
		load_plugin(spec)
	end
	for _, spec in ipairs(lazy) do
		register_lazy_triggers(spec)
	end

	vim.api.nvim_create_user_command("Pack", function(opts)
		local sub = opts.fargs[1]
		if sub == "update" or sub == nil then
			vim.pack.update()
		elseif sub == "health" then
			vim.cmd("checkhealth vim.pack pack")
		elseif sub == "log" then
			vim.cmd("checkhealth vim.pack")
		elseif sub == "list" then
			local rows = {}
			for _, s in ipairs(state.specs) do
				rows[#rows + 1] = ("%s  %s  [%s]"):format(
					s._loaded and "✓" or "·",
					s.name,
					is_lazy(s) and "lazy" or "eager"
				)
			end
			table.sort(rows)
			vim.notify(table.concat(rows, "\n"), vim.log.levels.INFO)
		else
			notify.warn("pack", "Unknown subcommand: " .. sub)
		end
	end, {
		nargs = "?",
		complete = function()
			return { "update", "health", "log", "list" }
		end,
		desc = "Pack: update | health | log | list",
	})
end

function M.specs()
	return state.specs, state.disabled
end

function M.is_loaded(name)
	local s = state.by_name[name]
	return s and s._loaded == true
end

return M
