vim.g.mapleader = " "
vim.g.maplocalleader = ","

require("config.options")
require("config.autocmds")

vim.pack.add({ "https://github.com/zuqini/zpack.nvim" })
require("zpack").setup({ cmd_name = "Pack" })

require("config.diagnostics")
require("config.lsp")
require("config.keymaps")
