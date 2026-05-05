local M = {}

function M.check()
	local h = vim.health
	local pack = require("util.pack")
	local specs = pack.specs()

	h.start("pack")

	local missing = false
	for _, spec in ipairs(specs) do
		if spec.install and spec.install.binaries then
			for _, bin in ipairs(spec.install.binaries) do
				local exe = bin:match("^[%w_-]+")
				if vim.fn.executable(exe) == 1 then
					h.ok(("%s found (%s)"):format(bin, spec.name))
				else
					missing = true
					h.warn(("%s not found (%s)"):format(bin, spec.name))

					local hints = {}
					if spec.install.packages then
						for mgr, pkgs in pairs(spec.install.packages) do
							for _, pkg in ipairs(pkgs) do
								hints[#hints + 1] = mgr .. " install " .. pkg
							end
						end
					end
					for _, note in ipairs(spec.install.notes or {}) do
						hints[#hints + 1] = note
					end
					if #hints > 0 then
						h.info("Install hints:\n  " .. table.concat(hints, "\n  "))
					end
				end
			end
		end
	end

	if not missing then
		h.ok("All declared plugin binaries are on PATH")
	end

	h.info("Run :checkhealth vim.pack for plugin/lockfile state")
end

return M
