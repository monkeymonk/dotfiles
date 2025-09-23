-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
local command = require("utils.command")
local autocmd = command.autocmd

-- Aliases
vim.cmd(string.format("command! %s %s", "Q", "qa"))

-- Disable the concealing in some file formats
-- The default conceallevel is 3 in LazyVim
autocmd("FileType", {
  callback = function()
    vim.wo.conceallevel = 0
  end,
  pattern = { "json", "jsonc", "markdown" },
})

-- Spell check markdown files
autocmd({ "BufRead", "BufNewFile" }, {
  command = "setlocal spell",
  desc = "Spell check markdown files",
  group = "buffer",
  pattern = { "*.md", "*.txt" },
})
autocmd("FileType", {
  callback = function()
    vim.opt.spell = true
    vim.opt.spelllang = { "en_us" }
  end,
  desc = "Enable spell checking in markdown files",
  group = "buffer",
  pattern = "*.md",
})

-- Strip trailing whitespace from all files
autocmd("BufWritePre", {
  command = "%s/s+$//e",
  desc = "Strip trailing whitespace from all files",
  group = "buffer",
  pattern = "*",
})

-- Turn relative number on in normal mode
autocmd({ "BufEnter", "FocusGained", "InsertLeave", "CmdlineLeave", "WinEnter" }, {
  callback = function()
    if vim.o.nu and vim.api.nvim_get_mode().mode ~= "i" then
      vim.opt.relativenumber = true
    end
  end,
  group = "linenumber",
  pattern = "*",
})

-- Turn relative number off in insert mode or when window loses focus
autocmd({ "BufLeave", "FocusLost", "InsertEnter", "CmdlineEnter", "WinLeave" }, {
  callback = function()
    if vim.o.nu then
      vim.opt.relativenumber = false
      vim.cmd("redraw")
    end
  end,
  group = "linenumber",
  pattern = "*",
})

-- Start git messages in insert mode
autocmd("FileType", {
  command = "startinsert | 1",
  desc = "Start git messages in insert mode",
  group = "buffer",
  pattern = { "gitcommit", "gitrebase" },
})

--[[ -- Autocommand to temporarily change 'blade' filetype to 'php' when opening for LSP server activation
autocmd({ "BufRead", "BufNewFile" }, function()
  vim.bo.filetype = "php"
end, { group = "lsp_blade_workaround", pattern = "*.blade.php" })

-- Additional autocommand to switch back to 'blade' after LSP has attached
autocmd("LspAttach", function(args)
  vim.schedule(function()
    -- Check if the attached client is 'intelephense'
    for _, client in ipairs(vim.lsp.get_active_clients()) do
      if client.name == "intelephense" and client.attached_buffers[args.buf] then
        vim.api.nvim_buf_set_option(args.buf, "filetype", "blade")
        -- update treesitter parser to blade
        vim.api.nvim_buf_set_option(args.buf, "syntax", "blade")
        break
      end
    end
  end)
end, { pattern = "*.blade.php" }) ]]

-- make $ part of the keyword for php.
vim.api.nvim_exec([[ autocmd FileType php set iskeyword+=$ ]], false)
