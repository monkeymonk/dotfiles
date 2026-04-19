-- lua/util/pack/spec.lua
local M = {}

local notify = require("util.notify")

local function scandir(path)
	local files = {}
	local handle = vim.uv.fs_scandir(path)
	if not handle then
		return files
	end
	while true do
		local name, typ = vim.uv.fs_scandir_next(handle)
		if not name then
			break
		end
		if typ == "file" and name:sub(-4) == ".lua" then
			files[#files + 1] = name:gsub("%.lua$", "")
		end
	end
	table.sort(files)
	return files
end

function M.normalize(val)
	if val == nil then
		return {}
	end
	if type(val) == "string" then
		return { val }
	end
	return val
end

local function is_enabled(spec)
	if spec.enabled == nil then
		return true
	end
	if type(spec.enabled) == "function" then
		return spec.enabled()
	end
	return spec.enabled == true
end

local function infer_name(spec, fallback)
	local src = spec.src or spec[1] or fallback
	if not src then
		return fallback
	end
	local name = src:match("([^/]+)$") or src
	return name:gsub("%.git$", "")
end

local function infer_main(spec)
	local name = spec.main or infer_name(spec, spec.name)
	return name
		:gsub("%.nvim$", "")
		:gsub("%.vim$", "")
		:gsub("%.lua$", "")
		:gsub("^nvim%-", "")
		:gsub("%-nvim$", "")
		:gsub("%-", ".")
end

local function make_setup(spec)
	if spec.setup ~= nil or (spec.opts == nil and spec.config == nil) then
		return spec.setup
	end

	local main = infer_main(spec)
	return function(plugin)
		local opts = spec.opts
		if type(opts) == "function" then
			opts = opts(plugin)
		end
		if opts == nil then
			opts = {}
		end

		if type(spec.config) == "function" then
			return spec.config(plugin, opts)
		end

		local ok, mod = pcall(require, main)
		if not ok then
			error(("Pack: failed to require main module '%s' for %s\n%s"):format(main, spec.name, mod))
		end
		if type(mod.setup) ~= "function" then
			error(("Pack: module '%s' for %s has no setup()"):format(main, spec.name))
		end

		return mod.setup(opts)
	end
end

local function normalize_key_entry(entry)
	if type(entry) == "string" then
		return {
			lhs = entry,
			mode = "n",
		}
	end
	if type(entry) ~= "table" then
		return nil
	end

	return {
		lhs = entry[1],
		rhs = entry[2],
		mode = entry.mode or "n",
		desc = entry.desc,
		expr = entry.expr,
		silent = entry.silent,
		remap = entry.remap,
		nowait = entry.nowait,
	}
end

local function normalize_keys(keys)
	if type(keys) == "function" or keys == nil then
		return keys
	end

	local normalized = {}
	for _, entry in ipairs(keys) do
		local item = normalize_key_entry(entry)
		if item and item.lhs then
			normalized[#normalized + 1] = item
		end
	end
	return normalized
end

local function normalize_version(spec)
	if spec.version ~= nil then
		return spec.version
	end
	return spec.tag or spec.branch or spec.commit
end

local function clone_spec(spec)
	local cloned = vim.deepcopy(spec)
	if cloned.src == nil and type(cloned[1]) == "string" then
		cloned.src = cloned[1]
	end
	return cloned
end

local function normalize_spec(spec, mod_name, acc)
	spec = clone_spec(spec)
	local raw_deps = spec.dependencies or spec.deps or {}

	spec.name = spec.name or infer_name(spec, mod_name)
	spec.priority = spec.priority or 50
	spec.version = normalize_version(spec)
	spec.dependencies = {}
	spec.dependency_names = {}
	spec.event = M.normalize(spec.event)
	spec.ft = M.normalize(spec.ft)
	spec.cmd = M.normalize(spec.cmd)
	spec.keys = normalize_keys(spec.keys)
	spec.setup = make_setup(spec)

	for _, dep in ipairs(raw_deps) do
		if type(dep) == "string" then
			spec.dependencies[#spec.dependencies + 1] = dep
		elseif type(dep) == "table" then
			local dep_spec = normalize_spec(dep, dep.name or dep[1], acc)
			if dep.lazy == nil and #dep_spec.event == 0 and #dep_spec.ft == 0 and #dep_spec.cmd == 0 and dep_spec.keys == nil then
				dep_spec.lazy = false
			end
			spec.dependencies[#spec.dependencies + 1] = dep_spec.src
			spec.dependency_names[#spec.dependency_names + 1] = dep_spec.name
			acc[#acc + 1] = dep_spec
		end
	end

	spec.deps = nil
	return spec
end

local function validate_spec(spec)
	if not spec.src then
		notify.warn("Pack", "Spec '" .. spec.name .. "' has no src")
	end
end

function M.is_lazy(spec)
	return spec.lazy == true
		or (type(spec.event) == "table" and #spec.event > 0)
		or (type(spec.event) == "string")
		or (type(spec.ft) == "table" and #spec.ft > 0)
		or (type(spec.ft) == "string")
		or (type(spec.cmd) == "table" and #spec.cmd > 0)
		or (type(spec.cmd) == "string")
		or (type(spec.keys) == "table" and #spec.keys > 0)
end

local function collect_spec(def, mod_name, all_specs, disabled_specs, seen)
	local function add_one(spec)
		local extras = {}
		local normalized = normalize_spec(spec, mod_name, extras)

		local bucket = is_enabled(normalized) and all_specs or disabled_specs
		if not seen[normalized.name] then
			validate_spec(normalized)
			bucket[#bucket + 1] = normalized
			seen[normalized.name] = true
		end

		for _, extra in ipairs(extras) do
			local extra_bucket = is_enabled(extra) and all_specs or disabled_specs
			if not seen[extra.name] then
				validate_spec(extra)
				extra_bucket[#extra_bucket + 1] = extra
				seen[extra.name] = true
			end
		end
	end

	if vim.islist(def) and type(def[1]) == "table" then
		for _, item in ipairs(def) do
			add_one(item)
		end
	else
		add_one(def)
	end
end

function M.load_specs()
	local all_specs = {}
	local disabled_specs = {}
	local seen = {}
	local plugin_dir = vim.fn.stdpath("config") .. "/lua/plugins"

	for _, mod in ipairs(scandir(plugin_dir)) do
		local ok, spec = pcall(require, "plugins." .. mod)
		if not ok then
			notify.error("Pack", "Failed to load spec: " .. mod .. "\n" .. spec)
		elseif type(spec) == "table" then
			collect_spec(spec, mod, all_specs, disabled_specs, seen)
		end
	end

	return all_specs, disabled_specs
end

function M.to_pack_sources(specs)
	local seen = {}
	local eager = {}
	local lazy = {}

	local function add(src, version, is_lazy_plugin)
		if not src or seen[src] then
			return
		end
		seen[src] = true
		local entry = { src = src }
		if version ~= nil then
			entry.version = version
		end
		if is_lazy_plugin then
			lazy[#lazy + 1] = entry
		else
			eager[#eager + 1] = entry
		end
	end

	for _, spec in ipairs(specs) do
		local lazy_plugin = M.is_lazy(spec)
		add(spec.src, spec.version, lazy_plugin)
		for _, dep in ipairs(spec.dependencies) do
			add(dep, nil, false)
		end
	end

	return eager, lazy
end

return M
