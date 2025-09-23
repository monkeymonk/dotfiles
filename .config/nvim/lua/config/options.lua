-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.backupskip = { "/tmp/*", "/private/tmp/*" } -- Exclude temporary files from backups.
vim.opt.smarttab = true -- Use smart tabbing for indents and dedents.
vim.opt.breakindent = true -- Enable break indent feature for better readability.
vim.opt.hlsearch = true -- Highlight search matches.
vim.opt.incsearch = true -- Incremental search.
vim.opt.whichwrap:append("<,>,[,],h,l") -- Allow moving cursor between lines and end of lines
vim.opt.hidden = true -- Enable background buffers
vim.opt.clipboard = "unnamedplus" -- Sync with system clipboard
vim.opt.completeopt = "menuone,popup,noselect" -- Allow auto completion

-- Add asterisks in block comments
vim.opt.formatoptions:append({ "r" })
vim.opt.commentstring = ""
vim.opt.expandtab = true

-- undo
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"

-- enable local configs
vim.opt.exrc = true
vim.opt.secure = true

vim.g.lazyvim_prettier_needs_config = false

-- Neovide is a graphical Vim front-end. These settings only apply if Neovide is in use.
-- @see https://neovide.dev/
if vim.g.neovide then
  vim.g.neovide_confirm_quit = true -- Enable confirmation dialog when quitting Neovide.
  vim.g.neovide_cursor_animation_length = 0 -- Disable cursor animation.
  vim.g.neovide_cursor_trail_length = 0 -- Disable cursor trail effect.
  vim.g.neovide_scale_factor = 0.8 -- Set the scaling factor for the Neovide window.
end
