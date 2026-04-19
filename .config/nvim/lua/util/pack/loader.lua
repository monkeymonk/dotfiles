-- lua/util/pack/loader.lua
local M = {}

local map = require("util.map")
local notify = require("util.notify")
local spec_mod = require("util.pack.spec")

local specs_by_name = {}

local function wrap_rhs(spec, rhs)
	if type(rhs) == "function" then
		local orig = rhs
		return function()
			M.load_plugin(spec)
			return orig()
		end
	elseif type(rhs) == "string" then
		local orig = rhs
		return function()
			M.load_plugin(spec)
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(orig, true, true, true), "m", false)
		end
	end
	return rhs
end

local function run_init(spec)
	if type(spec.init) ~= "function" or spec._init_ran then
		return
	end
	spec._init_ran = true

	local ok, err = pcall(spec.init, spec)
	if not ok then
		notify.error("Pack", "Init failed for " .. spec.name .. "\n" .. err)
	end
end

local function register_key_entries(spec, keys, is_lazy)
	for _, key in ipairs(keys) do
		local rhs = key.rhs
		if rhs ~= nil then
			rhs = wrap_rhs(spec, rhs)
		elseif is_lazy then
			rhs = function()
				M.load_plugin(spec)
			end
		else
			rhs = nil
		end

		if rhs ~= nil then
			map.map(key.mode, key.lhs, rhs, key.desc, {
				expr = key.expr,
				silent = key.silent,
				remap = key.remap,
				nowait = key.nowait,
			})
		end
	end
end

local function make_lazy_map(spec)
	local proxy = {}

	proxy.map = function(mode, lhs, rhs, desc, extra)
		map.map(mode, lhs, wrap_rhs(spec, rhs), desc, extra)
	end

	for _, mode in ipairs({ "n", "x", "v", "i", "t" }) do
		proxy[mode] = function(lhs, rhs, desc, extra)
			map[mode](lhs, wrap_rhs(spec, rhs), desc, extra)
		end
	end

	return proxy
end

function M.load_plugin(spec)
	if spec._loaded then
		return
	end

	if type(spec.cond) == "function" then
		local ok, result = pcall(spec.cond)
		if ok and not result then
			return
		end
	elseif spec.cond == false then
		return
	end

	spec._loaded = true

	for _, dep_name in ipairs(spec.dependency_names or {}) do
		local dep = specs_by_name[dep_name]
		if dep then
			M.load_plugin(dep)
		end
	end

	-- Lazy plugins were registered with load=noop, so packadd them into runtime
	if spec_mod.is_lazy(spec) then
		local pack_name = spec.src and spec.src:match("([^/]+)$") or spec.name
		pcall(vim.cmd.packadd, pack_name)
	end

	if type(spec.setup) == "function" then
		local ok, err = pcall(spec.setup, spec)
		if not ok then
			notify.error("Pack", "Setup failed for " .. spec.name .. "\n" .. err)
		end
	end

	if type(spec.keys) == "function" then
		local ok, err = pcall(spec.keys, map, spec)
		if not ok then
			notify.error("Pack", "Keymaps failed for " .. spec.name .. "\n" .. err)
		end
	elseif type(spec.keys) == "table" then
		register_key_entries(spec, spec.keys, false)
	end
end

local function setup_lazy(spec)
	-- Register keymaps eagerly with wrappers that trigger load on first use
	if type(spec.keys) == "function" then
		local lazy_map = make_lazy_map(spec)
		local ok, err = pcall(spec.keys, lazy_map, spec)
		if not ok then
			notify.error("Pack", "Keymaps failed for " .. spec.name .. "\n" .. err)
		end
	elseif type(spec.keys) == "table" then
		register_key_entries(spec, spec.keys, true)
	end

	local has_trigger = false

	if #spec.event > 0 then
		local group = vim.api.nvim_create_augroup("pack_" .. spec.name, { clear = true })
		for _, event in ipairs(spec.event) do
			local ev, pattern = event:match("^(%S+)%s+(.+)$")
			if not ev then
				ev = event
			end
			vim.api.nvim_create_autocmd(ev, {
				group = group,
				pattern = pattern,
				once = true,
				callback = function()
					vim.api.nvim_del_augroup_by_id(group)
					M.load_plugin(spec)
				end,
			})
		end
		has_trigger = true
	end

	if #spec.ft > 0 then
		local group = vim.api.nvim_create_augroup("pack_ft_" .. spec.name, { clear = true })
		vim.api.nvim_create_autocmd("FileType", {
			group = group,
			pattern = spec.ft,
			once = true,
			callback = function(args)
				vim.api.nvim_del_augroup_by_id(group)
				M.load_plugin(spec)
				vim.api.nvim_exec_autocmds("FileType", { buffer = args.buf })
			end,
		})
		has_trigger = true
	end

	if #spec.cmd > 0 then
		for _, cmd in ipairs(spec.cmd) do
			vim.api.nvim_create_user_command(cmd, function(ctx)
				vim.api.nvim_del_user_command(cmd)
				M.load_plugin(spec)
				local bang = ctx.bang and "!" or ""
				local input = cmd .. bang .. " " .. ctx.args
				vim.cmd(input)
			end, { nargs = "*", bang = true, complete = "file" })
		end
		has_trigger = true
	end

	if not has_trigger then
		vim.api.nvim_create_autocmd("UIEnter", {
			once = true,
			callback = function()
				vim.schedule(function()
					M.load_plugin(spec)
				end)
			end,
		})
	end
end

function M.run(specs)
	specs_by_name = {}
	local eager = {}
	local lazy = {}

	for _, spec in ipairs(specs) do
		specs_by_name[spec.name] = spec
		run_init(spec)
		if spec_mod.is_lazy(spec) then
			lazy[#lazy + 1] = spec
		else
			eager[#eager + 1] = spec
		end
	end

	table.sort(eager, function(a, b)
		return a.priority > b.priority
	end)

	for _, spec in ipairs(eager) do
		M.load_plugin(spec)
	end

	for _, spec in ipairs(lazy) do
		setup_lazy(spec)
	end
end

return M
