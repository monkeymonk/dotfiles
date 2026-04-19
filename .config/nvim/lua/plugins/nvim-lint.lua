return {
	name = "nvim-lint",
	src = "https://github.com/mfussenegger/nvim-lint",
	event = { "BufReadPost", "BufNewFile" },

	install = {
		binaries = {
			"eslint_d",
			"phpcs",
			"markdownlint",
			"yamllint",
			"shellcheck",
		},
		packages = {
			npm = { "eslint_d", "markdownlint-cli" },
			composer = { "squizlabs/php_codesniffer" },
			pip = { "yamllint" },
		},
		notes = {
			"Go/Rust linting handled by gopls/rust-analyzer via LSP.",
		},
	},

	setup = function()
		local lint = require("lint")

		lint.linters_by_ft = {
			javascript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescript = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			php = { "phpcs" },
			markdown = { "markdownlint" },
			yaml = { "yamllint" },
			sh = { "shellcheck" },
			bash = { "shellcheck" },
		}

		local group = vim.api.nvim_create_augroup("user_lint", { clear = true })
		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = group,
			callback = function()
				pcall(lint.try_lint)
			end,
		})
	end,
}
