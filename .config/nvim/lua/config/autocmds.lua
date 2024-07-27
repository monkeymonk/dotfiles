-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
local command = require("utils.command")
local alias = command.alias
local autocmd = command.autocmd
local cmd = command.cmd

-- =============================================================================
-- Custom Commands
-- =============================================================================
-- @see: https://github.com/charmbracelet/mods
-- @TODO:
--[[ -- Explain the selected range
cmd("ModsExplain", function(range)
  local start_line, end_line = unpack(range)
  vim.fn.setline(".", "'<,'>w !mods explain this, be very succinct")
end)

-- @TODO:
-- Refactor the selected range for readability
cmd("ModsRefactor", function(range, ...)
  local start_line, end_line = unpack(range)
  local args = table.concat({ ... }, " ")
  vim.fn.setline(".", "'<,'>!mods refactor this to improve its readability")
end)

-- @TODO:
-- Send the selected range to a mod with additional arguments
cmd("Mods", function(range, ...)
  local start_line, end_line = unpack(range)
  local args = table.concat({ ... }, " ")
  vim.fn.setline(".", "'<,'>w !mods " .. args)
end) ]]

cmd("SaveAs", function()
  local saveas = vim.fn.input("Save file as: ")
  vim.cmd("saveas " .. saveas)
end, { nargs = 0 })

-- =============================================================================
-- Auto Commands
-- =============================================================================

-- Close specific buffer types with `q`
autocmd("FileType", function(event)
  vim.bo[event.buf].buflisted = false
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
end, {
  pattern = {
    "blame",
    "checkhealth",
    "help",
    "lspinfo",
    "man",
    "neoai",
    "neotest-summary",
    "notify",
    "PlenaryTestPopup",
    "qf",
    "spectre_panel",
    "startuptime",
    "toggleterm",
    "tsplayground",
  },
})

-- Disable the concealing in some file formats
-- The default conceallevel is 3 in LazyVim
autocmd("FileType", function()
  vim.opt.conceallevel = 0
end, {
  pattern = { "json", "jsonc", "markdown" },
})

-- =============================================================================
-- Command Aliases
-- =============================================================================

-- Basic command aliases for quitting, writing, and both
alias("Q", "qa")
alias("W", "w")
alias("WQ", "wqa")
