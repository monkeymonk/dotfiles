return {
	name = "render-markdown",
	src = "https://github.com/MeanderingProgrammer/render-markdown.nvim",
	ft = { "markdown", "codecompanion" },

	config = function()
		require("render-markdown").setup({
			file_types = { "markdown", "codecompanion" },
			render_modes = true,
		})
	end,

	keys = {
		{
			"<leader>uM",
			function()
				local ok, rm = pcall(require, "render-markdown")
				if ok and rm.toggle then
					rm.toggle()
				end
			end,
			desc = "Toggle markdown render",
		},
	},
}
