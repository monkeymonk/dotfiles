vim.g.mapleader = " "
vim.g.maplocalleader = ","

require("config.options")
require("config.autocmds")
require("util.pack").setup()
require("config.diagnostics")
require("config.lsp")
require("config.keymaps")

require("util.pack").boot()
