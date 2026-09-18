local opts = {
	file_types = { "markdown", "codecompanion" },
	render_modes = true,
	overrides = {
		filetype = {
			-- codecompanion's auto_scroll parks the cursor on the streaming
			-- line, so anti-conceal would leave the live response looking
			-- unrendered. Real files keep it.
			codecompanion = {
				anti_conceal = { enabled = false },
			},
		},
	},
}

return {
	name = "render-markdown",
	src = "https://github.com/MeanderingProgrammer/render-markdown.nvim",
	ft = { "markdown", "codecompanion" },

	config = function()
		-- snacks' markdown preview does `pcall(require, "render-markdown")`.
		-- zpack answers a require with `packadd!`, which puts the plugin on the
		-- runtimepath but never sources plugin/, then marks the spec loaded so
		-- the `ft` trigger short-circuits. plugin/ is what calls manager.init()
		-- — the FileType autocmd that attaches the renderer — so losing that
		-- race means nothing renders all session, chat buffers included.
		-- Sourcing it here is a no-op when the `ft` path already did: the file
		-- guards itself with vim.g.loaded_render_markdown.
		vim.g.render_markdown_config = opts
		vim.cmd.runtime("plugin/render-markdown.lua")
		require("render-markdown").setup(opts)
	end,
}
