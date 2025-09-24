-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

-- Disable Ex mode mapping
vim.keymap.set("n", "Q", "<Nop>", { silent = true })

-- CapsLock as Esc
vim.keymap.set({ "n", "v", "i" }, "<CapsLock>", "<Esc>", { noremap = true, silent = true })

-- Buffer next/prev
vim.keymap.set("n", "<Tab>", "<cmd> bnext <CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", "<cmd> bprev <CR>", { desc = "Previous buffer" })

-- Incremt / decrement
vim.keymap.set("n", "+", "<C-a>", { desc = "Increment" })
vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement" })

-- Paste using `Ctrl+v` in insert mode
vim.keymap.set("i", "<C-v>", "<C-r>+", { desc = "Paste" })

-- Clear search highlights using `Backspace` and `Esc` in normal mode
vim.keymap.set("n", "<BS>", "<cmd> nohlsearch <CR>", { desc = "Clear search highlights" })
vim.keymap.set("n", "<Esc>", "<cmd> nohlsearch <CR>", { desc = "Clear search highlights" })

-- Indent / unindent in visual mode using `Tab` and `Shift+Tab`
vim.keymap.set("v", "<Tab>", ">gv", { desc = "Indent" })
vim.keymap.set("v", "<S-Tab>", "<gv", { desc = "Unindent" })

-- Use `x` and `Del` for black hole register (deleting without affecting clipboard)
vim.keymap.set("n", "<Del>", '"_x', { desc = "Delete without clipboard" })
vim.keymap.set("n", "x", '"_x', { desc = "Delete without clipboard" })

-- Use `<leader>P` to paste without clipboard
vim.keymap.set("n", "<leader>P", '"_dP', { desc = "Paste without clipboard" })

-- Exit terminal mode using `Esc`
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal" })

vim.keymap.set("n", "<leader>fg", function()
  require("fzf-lua").live_grep({
    cwd = vim.fn.expand("%:p:h"), -- Utilise le dossier du buffer courant
  })
end, { desc = "Live grep in current buffer directory" })
