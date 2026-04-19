-- lua/util/pack/health.lua
local M = {}

function M.check()
	local h = vim.health
	local pack = require("util.pack")
	local specs = pack.get_specs()

	h.start("pack")

	local missing_any = false

	for _, spec in ipairs(specs) do
		if spec.install and spec.install.binaries then
			for _, bin in ipairs(spec.install.binaries) do
				if vim.fn.executable(bin) == 1 then
					h.ok(bin .. " found (" .. spec.name .. ")")
				else
					missing_any = true
					h.warn(bin .. " not found (" .. spec.name .. ")")

					local advice = {}
					if spec.install.packages then
						for manager, pkgs in pairs(spec.install.packages) do
							for _, pkg in ipairs(pkgs) do
								advice[#advice + 1] = manager .. " install " .. pkg
							end
						end
					end
					if spec.install.notes then
						for _, note in ipairs(spec.install.notes) do
							advice[#advice + 1] = note
						end
					end
					if #advice > 0 then
						h.info("Install hints:\n  " .. table.concat(advice, "\n  "))
					end
				end
			end
		end
	end

	if not missing_any then
		h.ok("All plugin binaries accounted for")
	end

	h.info("Run :checkhealth vim.pack for lockfile and installation health")
end

return M
