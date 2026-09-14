return {
	name = "package-info",
	src = "https://github.com/vuki656/package-info.nvim",
	dependencies = {
		"MunifTanjim/nui.nvim",
	},
	ft = "json",

	config = function()
		require("package-info").setup({
			hide_unstable_versions = true,
			package_manager = "npm",
		})
	end,

	keys = {
		{
			"<leader>cds",
			function()
				require("package-info").show()
			end,
			desc = "Show dependency versions",
		},
		{
			"<leader>cdt",
			function()
				require("package-info").toggle()
			end,
			desc = "Toggle dependency versions",
		},
		{
			"<leader>cdi",
			function()
				require("package-info").install()
			end,
			desc = "Install dependency",
		},
		{
			"<leader>cdu",
			function()
				require("package-info").change_version()
			end,
			desc = "Change dependency version",
		},
	},
}
