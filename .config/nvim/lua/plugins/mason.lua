return {
	name = "mason",
	src = "https://github.com/mason-org/mason.nvim",
	dependencies = {
		"https://github.com/mason-org/mason-lspconfig.nvim",
	},

	install = {
		notes = {
			"mason-lspconfig auto-enables LSP servers configured via vim.lsp.config().",
			":MasonEnsure auto-installs every package declared by LSP/plugin specs.",
			":MasonEnsureList previews what would be installed without doing it.",
		},
	},

	setup = function()
		require("mason").setup({
			ui = { border = "rounded" },
		})

		local ok_mlc, mlc = pcall(require, "mason-lspconfig")
		if ok_mlc then
			local servers = require("config.lsp.servers")
			local names = vim.tbl_keys(servers)
			table.sort(names)
			mlc.setup({ automatic_enable = names })
		end

		local ensure = require("util.mason_ensure")
		ensure.setup()

		vim.api.nvim_create_autocmd("UIEnter", {
			once = true,
			callback = function()
				vim.defer_fn(ensure.ensure, 500)
			end,
		})
	end,
}
