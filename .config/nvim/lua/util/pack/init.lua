-- lua/util/pack/init.lua
local M = {}

local notify = require("util.notify")
local spec_mod = require("util.pack.spec")
local loader = require("util.pack.loader")

local state = {
	specs = {},
	disabled = {},
	specs_by_name = {},
}

local function register_build_hooks()
	vim.api.nvim_create_autocmd("PackChanged", {
		callback = function(ev)
			local name = ev.data.spec.name
			local kind = ev.data.kind
			if kind == "delete" then
				return
			end

			local s = state.specs_by_name[name]
			if not s or not s.build then
				return
			end

			if not ev.data.active then
				pcall(vim.cmd.packadd, name)
			end

			if type(s.build) == "function" then
				local ok, err = pcall(s.build, s)
				if not ok then
					notify.error("Pack", "Build failed for " .. name .. "\n" .. err)
				end
			elseif type(s.build) == "string" then
				local ok, err = pcall(vim.cmd, s.build)
				if not ok then
					notify.error("Pack", "Build failed for " .. name .. "\n" .. err)
				end
			end
		end,
	})
end

function M.setup()
	if vim.fn.has("nvim-0.12") == 0 then
		notify.error("Pack", "Requires Neovim >= 0.12")
		return
	end

	local specs, disabled = spec_mod.load_specs()
	state.specs = specs
	state.disabled = disabled

	for _, s in ipairs(specs) do
		state.specs_by_name[s.name] = s
	end
	for _, s in ipairs(disabled) do
		state.specs_by_name[s.name] = s
	end

	register_build_hooks()

	local eager_sources, lazy_sources = spec_mod.to_pack_sources(specs)

	if #eager_sources > 0 then
		vim.pack.add(eager_sources)
	end
	if #lazy_sources > 0 then
		vim.pack.add(lazy_sources, { load = function() end })
	end
end

function M.boot()
	loader.run(state.specs)

	local function open_pack_ui()
		require("util.pack.ui").open()
	end

	vim.api.nvim_create_user_command("Pack", open_pack_ui, { desc = "Open pack manager UI" })
	vim.api.nvim_create_user_command("Plugins", open_pack_ui, { desc = "Open pack manager UI" })
	vim.api.nvim_create_user_command("Plugin", open_pack_ui, { desc = "Open pack manager UI" })
end

function M.get_specs()
	return state.specs, state.disabled
end

function M.is_loaded(name)
	local s = state.specs_by_name[name]
	return s ~= nil and s._loaded == true
end

return M
