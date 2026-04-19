local M = {}

---@param mode string|string[]
---@param lhs string
---@param rhs string|function
---@param desc? string
---@param extra? table
function M.map(mode, lhs, rhs, desc, extra)
	local opts = vim.tbl_extend("force", {
		noremap = true,
		silent = true,
		desc = desc,
	}, extra or {})

	vim.keymap.set(mode, lhs, rhs, opts)
end

---@param specs table[]
---@param defaults? { mode?: string|string[], extra?: table }
function M.batch(specs, defaults)
	defaults = defaults or {}

	for _, spec in ipairs(specs) do
		local lhs = spec.lhs or spec[1]
		local rhs = spec.rhs or spec[2]
		local desc = spec.desc
		local extra = vim.tbl_deep_extend("force", defaults.extra or {}, spec.extra or {})

		if spec.expr ~= nil then
			extra.expr = spec.expr
		end
		if spec.silent ~= nil then
			extra.silent = spec.silent
		end
		if spec.remap ~= nil then
			extra.remap = spec.remap
		end
		if spec.nowait ~= nil then
			extra.nowait = spec.nowait
		end

		M.map(spec.mode or defaults.mode or "n", lhs, rhs, desc, extra)
	end
end

function M.n(lhs, rhs, desc, extra)
	M.map("n", lhs, rhs, desc, extra)
end

function M.x(lhs, rhs, desc, extra)
	M.map("x", lhs, rhs, desc, extra)
end

function M.v(lhs, rhs, desc, extra)
	M.map("v", lhs, rhs, desc, extra)
end

function M.i(lhs, rhs, desc, extra)
	M.map("i", lhs, rhs, desc, extra)
end

function M.t(lhs, rhs, desc, extra)
	M.map("t", lhs, rhs, desc, extra)
end

return M
