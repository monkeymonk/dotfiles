return {
	name = "package-info",
	src = "https://github.com/vuki656/package-info.nvim",
	dependencies = {
		"https://github.com/MunifTanjim/nui.nvim",
	},
	ft = "json",

	setup = function()
		require("package-info").setup({
			hide_unstable_versions = true,
			package_manager = "npm",
		})
	end,

	keys = function(map)
		map.n("<leader>cps", function()
			require("package-info").show()
		end, "Show dependency versions")

		map.n("<leader>cpt", function()
			require("package-info").toggle()
		end, "Toggle dependency versions")

		map.n("<leader>cpi", function()
			require("package-info").install()
		end, "Install dependency")

		map.n("<leader>cpu", function()
			require("package-info").change_version()
		end, "Change dependency version")
	end,
}
