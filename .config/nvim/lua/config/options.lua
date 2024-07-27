-- =============================================================================
-- LazyVim Configuration File
-- =============================================================================
-- This file contains additional configuration options for LazyVim, a Vim configuration framework.
-- Options are automatically loaded before lazy.nvim startup.
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here.

-- Accessing global and option variables from Vim
local g = vim.g
local opt = vim.opt

-- =============================================================================
-- General Settings
-- =============================================================================
-- Leader keys are used in Vim as a prefix to create custom shortcuts.
g.mapleader = " " -- Set the leader key to the spacebar for global commands.
g.maplocalleader = " " -- Set the local leader key to the spacebar for buffer-local commands.

-- These options improve file handling and editing experience.
vim.scriptencoding = "utf-8" -- Set script encoding to UTF-8.
opt.encoding = "utf-8" -- Set internal character encoding to UTF-8.
opt.autoread = true -- Automatically reload files when changed outside of Vim.
opt.fileencoding = "utf-8" -- Set file character encoding to UTF-8.
opt.number = true -- Display line numbers.
opt.relativenumber = false -- set relative numbered lines
opt.autoindent = true -- Enable automatic indentation.
opt.smartindent = true -- Enable smart indentation for code.
opt.backup = false -- Disable backup file creation.
opt.showcmd = true -- Show command in the bottom bar.

-- Pop-Up Menu and Command Line Settings
opt.pumheight = 10 -- Set the maximum number of items in the pop-up menu.
opt.cmdheight = 1 -- Set the height of the command line area.

-- Scrolling and Tab Settings
opt.scrolloff = 10 -- Set the minimum number of lines to keep above and below the cursor.
opt.backupskip = { "/tmp/*", "/private/tmp/*" } -- Exclude temporary files from backups.
opt.smarttab = true -- Use smart tabbing for indents and dedents.
opt.breakindent = true -- Enable break indent feature for better readability.

-- Add asterisks in block comments
opt.formatoptions:append({ "r" })
opt.commentstring = ""
opt.expandtab = true

-- =============================================================================
-- Navigation & Buffer
-- =============================================================================
opt.whichwrap:append("<,>,[,],h,l") -- Allow moving cursor between lines and end of lines
opt.hidden = true -- Enable background buffers
opt.list = true -- Show invisible characters (like tabs and trailing spaces).

-- Sync with system clipboard
opt.clipboard = "unnamedplus"

-- Allow auto completion
opt.completeopt = "menuone,popup,noselect"

-- =============================================================================
-- Neovide Settings (GUI-specific)
-- =============================================================================
-- Neovide is a graphical Vim front-end. These settings only apply if Neovide is in use.
if g.neovide then
  g.neovide_confirm_quit = true -- Enable confirmation dialog when quitting Neovide.
  g.neovide_cursor_animation_length = 0 -- Disable cursor animation.
  g.neovide_cursor_trail_length = 0 -- Disable cursor trail effect.
  g.neovide_scale_factor = 0.8 -- Set the scaling factor for the Neovide window.
end
