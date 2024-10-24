-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
local command = require("utils.command")
local alias = command.alias
local autocmd = command.autocmd

alias("Q", "qa")
alias("W", "w")

-- Disable the concealing in some file formats
-- The default conceallevel is 3 in LazyVim
autocmd("FileType", function()
  vim.wo.conceallevel = 0
end, { pattern = { "json", "jsonc", "markdown" } })

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
