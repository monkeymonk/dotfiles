-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local keymap = require("utils.keymap")
local bind = keymap.bind
local desc = keymap.desc

-- Disable `Ctrl+z` (for Kitty terminal)
--bind("ni", "<C-z>", "<Nop>")

-- Disable Ex mode mapping
bind("n", "Q", "<Nop>", { silent = true })

-- CapsLock as Esc
bind("nvi", "<CapsLock>", "<Esc>", { noremap = true, silent = true })

-- Buffer next/prev
bind("n", "<Tab>", "<cmd> bnext <CR>", desc("Next buffer"))
bind("n", "<S-Tab>", "<cmd> bprev <CR>", desc("Previous buffer"))

-- Incremt / decrement
bind("n", "+", "<C-a>", desc("Increment"))
bind("n", "-", "<C-x>", desc("Decrement"))

-- Paste using `Ctrl+v` in insert mode
bind("i", "<C-v>", "<C-r>+", desc("Paste"))

-- Clear search highlights using `Backspace` and `Esc` in normal mode
bind("n", "<BS>", "<cmd> nohlsearch <CR>", desc("Clear search highlights"))
bind("n", "<Esc>", "<cmd> nohlsearch <CR>", desc("Clear search highlights"))

-- Indent / unindent in visual mode using `Tab` and `Shift+Tab`
bind("v", "<Tab>", ">gv", desc("Indent"))
bind("v", "<S-Tab>", "<gv", desc("Unindent"))

-- Use `x` and `Del` for black hole register (deleting without affecting clipboard)
bind("n", "<Del>", '"_x', desc("Delete without clipboard"))
bind("n", "x", '"_x', desc("Delete without clipboard"))

-- Use `<leader>P` to paste without clipboard
bind("n", "<leader>P", '"_dP', desc("Paste without clipboard"))

-- Exit terminal mode using `Esc`
bind("t", "<Esc>", "<C-\\><C-n>", desc("Exit terminal"))

vim.keymap.set("n", "<leader>fg", function()
  require("fzf-lua").live_grep({
    cwd = vim.fn.expand("%:p:h"), -- Utilise le dossier du buffer courant
  })
end, { desc = "Live grep in current buffer directory" })
