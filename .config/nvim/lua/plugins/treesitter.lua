return {
	name = "treesitter",
	src = "https://github.com/nvim-treesitter/nvim-treesitter",
	build = "TSUpdate",
	dependencies = {
		"https://github.com/EmranMR/tree-sitter-blade",
	},

	install = {
		notes = {
			"Parsers install on demand when you open a supported filetype.",
			"Run :TSUpdate after plugin updates if parser queries drift.",
		},
	},

	setup = function()
		local ts = require("nvim-treesitter")
		ts.setup({})

		pcall(vim.treesitter.language.register, "blade", "blade")

		local parsers = {
			"bash",
			"blade",
			"css",
			"diff",
			"dockerfile",
			"gdscript",
			"gdshader",
			"git_config",
			"git_rebase",
			"gitcommit",
			"gitignore",
			"go",
			"gomod",
			"gosum",
			"gowork",
			"html",
			"javascript",
			"json",
			"lua",
			"luadoc",
			"markdown",
			"markdown_inline",
			"php",
			"python",
			"query",
			"regex",
			"rust",
			"toml",
			"tsx",
			"typescript",
			"vim",
			"vimdoc",
			"yaml",
		}
		ts.install(parsers)

		local installing = {}
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
			callback = function(args)
				local ft = vim.bo[args.buf].filetype
				if ft == "" then
					return
				end
				local lang = vim.treesitter.language.get_lang(ft) or ft

				if vim.list_contains(ts.get_installed(), lang) then
					pcall(vim.treesitter.start, args.buf, lang)
					return
				end

				if installing[lang] or not vim.list_contains(ts.get_available(), lang) then
					return
				end

				installing[lang] = true
				ts.install({ lang }):await(function()
					installing[lang] = nil
					if vim.api.nvim_buf_is_valid(args.buf) and vim.bo[args.buf].filetype == ft then
						pcall(vim.treesitter.start, args.buf, lang)
					end
				end)
			end,
		})
	end,
}
