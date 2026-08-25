return {
	name = "treesitter",
	src = "https://github.com/nvim-treesitter/nvim-treesitter",
	build = "TSUpdate",
	dependencies = {
		"EmranMR/tree-sitter-blade",
	},

	install = {
		notes = {
			"Parsers install on demand when you open a supported filetype.",
			"Run :TSUpdate after plugin updates if parser queries drift.",
		},
	},

	config = function()
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
			"vue",
			"vim",
			"vimdoc",
			"yaml",
		}
		ts.install(parsers)

		local installing = {}

		local function has_parser(lang)
			return vim.list_contains(ts.get_installed("parsers"), lang)
		end

		local function has_queries(lang)
			return #vim.api.nvim_get_runtime_file("queries/" .. lang .. "/highlights.scm", true) > 0
		end

		local function start(buf, ft, lang)
			if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == ft then
				pcall(vim.treesitter.start, buf, lang)
			end
		end

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
			callback = function(args)
				local ft = vim.bo[args.buf].filetype
				if ft == "" then
					return
				end
				local lang = vim.treesitter.language.get_lang(ft) or ft

				if has_parser(lang) and has_queries(lang) then
					pcall(vim.treesitter.start, args.buf, lang)
					return
				end

				if installing[lang] or not vim.list_contains(ts.get_available(), lang) then
					return
				end

				installing[lang] = true
				ts.install({ lang }, { force = has_parser(lang) and not has_queries(lang) }):await(function()
					installing[lang] = nil
					start(args.buf, ft, lang)
				end)
			end,
		})
	end,
}
