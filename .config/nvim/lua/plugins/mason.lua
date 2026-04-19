return {
	name = "mason",
	src = "https://github.com/mason-org/mason.nvim",
	dependencies = {
		"https://github.com/mason-org/mason-lspconfig.nvim",
	},

	install = {
		notes = {
			"Mason manages configured LSP servers, but installation is explicit via :Mason or :LspInstall.",
		},
	},
}
