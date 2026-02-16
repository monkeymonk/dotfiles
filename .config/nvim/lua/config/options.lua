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

-- Filetypes
-- Set .aliases or any variant as "bash"
vim.filetype.add({ pattern = { ["%.*aliases.*"] = "bash" } })

-- Set .zprofile or any variant as "bash"
vim.filetype.add({ pattern = { ["%.*zprofile.*"] = "bash" } })

-- Set .env or any variant as "dotenv" except we want .env.example files to be
-- treated differently so it's easier to know we are editing an example file.
-- This has less syntax highlighting and comes up with a different explorer
-- icon so it's easier to know it's not the "real" env file.
vim.filetype.add({
  pattern = {
    ["%.env.*"] = "dotenv",
    ["%.env.*.example"] = { "conf", { priority = 1 } },
  },
})

-- Ensure all .env files and variants are syntax highlighted as shell scripts.
-- This goes along with the filetype addition above. We do this to avoid using
-- bash or sh so the BashLSP linter and formatter doesn't affect env files
-- since that can create a lot of unwanted false positives and side effects.
vim.treesitter.language.register("bash", "dotenv")

-- Set git config variarts as "git_config".
vim.filetype.add({ pattern = { [".*/git/config.*"] = "git_config" } })

-- Set requirements-lock.txt or any variant as "requirements".
vim.filetype.add({ pattern = { ["requirements.*.txt"] = "requirements" } })

-- Set .blade.php files as "blade" (Laravel templates)
vim.filetype.add({ pattern = { [".*%.blade%.php"] = "blade" } })
