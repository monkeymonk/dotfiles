-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

opt.backupskip = { "/tmp/*", "/private/tmp/*" } -- Exclude temporary files from backups.
opt.smarttab = true -- Use smart tabbing for indents and dedents.
opt.breakindent = true -- Enable break indent feature for better readability.
opt.hlsearch = true -- Highlight search matches.
opt.incsearch = true -- Incremental search.
opt.whichwrap:append("<,>,[,],h,l") -- Allow moving cursor between lines and end of lines
opt.hidden = true -- Enable background buffers
opt.clipboard = "unnamedplus" -- Sync with system clipboard
opt.completeopt = "menuone,popup,noselect" -- Allow auto completion

-- Add asterisks in block comments
opt.formatoptions:append({ "r" })
opt.commentstring = ""
opt.expandtab = true

-- undo
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = os.getenv("HOME") .. "/.vim/undodir"

-- enable local configs
opt.exrc = true
opt.secure = true

local g = vim.g

g.lazyvim_prettier_needs_config = false

-- Neovide is a graphical Vim front-end. These settings only apply if Neovide is in use.
-- @see https://neovide.dev/
if g.neovide then
  g.neovide_confirm_quit = true -- Enable confirmation dialog when quitting Neovide.
  g.neovide_cursor_animation_length = 0 -- Disable cursor animation.
  g.neovide_cursor_trail_length = 0 -- Disable cursor trail effect.
  g.neovide_scale_factor = 0.8 -- Set the scaling factor for the Neovide window.
end
