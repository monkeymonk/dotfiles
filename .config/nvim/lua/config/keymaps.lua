-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local keymap = require("utils.keymap")
local bind = keymap.bind
local desc = keymap.desc

-- Disable some keymaps
bind("n", "<leader>ft", "<Nop>")
bind("n", "<leader>fT", "<Nop>")
bind("n", "<leader>`", "<Nop>")
bind("n", "<leader>K", "<Nop>")
bind("n", "<leader>l", "<Nop>")
bind("n", "<leader>L", "<Nop>")
bind("n", "<leader>|", "<Nop>")
bind("n", "<leader>gG", "<Nop>")

-- Disable `Ctrl+z` (for Kitty terminal)
bind("ni", "<C-z>", "<Nop>")

-- Incremt / decrement
bind("n", "+", "<C-a>", desc("Increment"))
bind("n", "-", "<C-x>", desc("Decrement"))

-- Indent / unindent in visual mode using `>` and `<`
bind("nv", ">", ">gv", desc("Indent"))
bind("nv", "<", "<gv", desc("Unindent"))

-- Indent / unindent in visual mode using `Tab` and `Shift+Tab`
bind("nv", "<Tab>", ">gv", desc("Indent"))
bind("nv", "<S-Tab>", "<gv", desc("Unindent"))

-- Use `x` and `Del` for black hole register (deleting without affecting clipboard)
bind("n", "<Del>", '"_x', desc("Delete without clipboard"))
bind("n", "x", '"_x', desc("Delete without clipboard"))

-- Exit terminal mode using `Esc`
bind("t", "<Esc>", "<C-\\><C-n>", desc("Exit terminal"))

-- Save, quit, and close buffer using `Ctrl+s`, `Ctrl+q`, and `Ctrl+w` respectively in insert mode
bind("ixsn", "<C-s>", "<Esc><cmd> w <CR>", desc("Save file"))
bind("i", "<C-q>", "<Esc><cmd> confirm qa <CR>", desc("Quit"))
bind("i", "<C-w>", "<Esc><cmd> confirm bdelete <CR>", desc("Close buffer"))

-- Copy using `Ctrl+c` in visual mode
bind("v", "<C-c>", "y", desc("Copy"))

-- Paste using `Ctrl+v` in insert mode
bind("i", "<C-v>", "<C-r>+", desc("Paste"))

-- Clear search highlights using `Backspace` and `Esc` in normal mode
bind("n", "<BS>", "<cmd> nohlsearch <CR>", desc("Clear search highlights"))
bind("n", "<Esc>", "<cmd> nohlsearch <CR>", desc("Clear search highlights"))

-- Select all
bind("n", "<C-a>", "gg<S-v>G", desc("Select all"))

-- Buffer next/prev
bind("n", "<Tab>", "<cmd> bnext <CR>", desc("Next buffer"))
bind("n", "<S-Tab>", "<cmd> bprev <CR>", desc("Previous buffer"))

-- Diagnostics
bind("n", "<C-j>", "<cmd?> lua vim.diagnostic.goto_next() <CR>", desc("Show diagnostic"))

-- Mote to window using <ctrl> arrow
bind("n", "<C-Left>", "<C-w>h", desc("Go to left window"))
bind("n", "<C-Right>", "<C-w>l", desc("Go to right window"))
bind("n", "<C-Down>", "<C-w>j", desc("Go to down window"))
bind("n", "<C-Up>", "<C-w>k", desc("Go to up window"))

-- Resize window using <ctrl> arrow keys
bind("n", "<C-k>", "<cmd>resize +0<cr>", desc("Increase window height"))
bind("n", "<C-j>", "<cmd>resize -0<cr>", desc("Decrease window height"))
bind("n", "<C-h>", "<cmd>vertical resize -0<cr>", desc("Decrease window width"))
bind("n", "<C-l>", "<cmd>vertical resize +0<cr>", desc("Increase window width"))
