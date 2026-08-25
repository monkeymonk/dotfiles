-- Static plugin-spec metadata, read directly from lua/plugins/*.lua.
--
-- Independent of the zpack runtime: this scans and requires each spec file
-- itself (the same files zpack imports) purely to read the `name` and
-- `install` fields plugin authors declare for :checkhealth pack and
-- :MasonEnsure. It never touches zpack's load state.
local M = {}

local function infer_name(src)
	if not src then
		return nil
	end
	return (src:match("([^/]+)$") or src):gsub("%.git$", "")
end

---@return { name: string, install: table? }[]
function M.list()
	local dir = vim.fn.stdpath("config") .. "/lua/plugins"
	local handle = vim.uv.fs_scandir(dir)
	if not handle then
		return {}
	end

	local out = {}
	while true do
		local fname, ftype = vim.uv.fs_scandir_next(handle)
		if not fname then
			break
		end
		if ftype == "file" and fname:sub(-4) == ".lua" then
			local mod = "plugins." .. fname:sub(1, -5)
			local ok, spec = pcall(require, mod)
			if ok and type(spec) == "table" and (spec.src or spec[1]) then
				out[#out + 1] = {
					name = spec.name or infer_name(spec.src or spec[1]),
					install = spec.install,
				}
			end
		end
	end
	return out
end

return M
