vim.diagnostic.config({
	virtual_text = {
		spacing = 2,
		prefix = "●",
		source = "if_many",
	},
	-- virtual_lines is owned by lsp_lines.nvim (toggled via <leader>ul).
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.HINT] = " ",
			[vim.diagnostic.severity.INFO] = " ",
		},
	},
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "rounded",
		source = "if_many",
	},
})
