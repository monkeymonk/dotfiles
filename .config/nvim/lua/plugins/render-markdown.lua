return {
	name = "render-markdown",
	src = "https://github.com/MeanderingProgrammer/render-markdown.nvim",
	ft = { "markdown", "codecompanion" },

	config = function()
		require("render-markdown").setup({
			file_types = { "markdown", "codecompanion" },
			render_modes = true,
			overrides = {
				filetype = {
					-- codecompanion's auto_scroll parks the cursor on the
					-- streaming line, so anti-conceal would leave the live
					-- response looking unrendered. Real files keep it.
					codecompanion = {
						anti_conceal = { enabled = false },
					},
				},
			},
		})
	end,
}
