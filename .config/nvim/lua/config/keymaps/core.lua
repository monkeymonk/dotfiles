local map = require("util.map")
local multicursor_ns = vim.api.nvim_create_namespace("nvim.multicursor")

local function clear_transient_state()
	vim.cmd.nohlsearch()
	vim.api.nvim_buf_clear_namespace(0, multicursor_ns, 0, -1)
end

map.batch({
	{ "<S-l>", "<cmd>bnext<cr>", desc = "Next buffer" },
	{ "<S-h>", "<cmd>bprevious<cr>", desc = "Previous buffer" },
	{ "+", "<C-a>", desc = "Increment number" },
	{ "-", "<C-x>", desc = "Decrement number" },
	{ "<Esc>", clear_transient_state, desc = "Clear search and multicursors" },
	{ "<BS>", "<cmd>nohlsearch<cr>", desc = "Clear search highlight" },
	{ "<C-Up>", "<cmd>resize -2<cr>", desc = "Resize split up" },
	{ "<C-Down>", "<cmd>resize +2<cr>", desc = "Resize split down" },
	{ "<C-Left>", "<cmd>vertical resize -2<cr>", desc = "Resize split left" },
	{ "<C-Right>", "<cmd>vertical resize +2<cr>", desc = "Resize split right" },
	{ "<leader>qq", "<cmd>qa<cr>", desc = "Quit all" },
}, { mode = "n" })

map.batch({
	{ "<Tab>", ">gv", desc = "Indent" },
	{ "<S-Tab>", "<gv", desc = "Unindent" },
}, { mode = "v" })

map.batch({
	{ "x", '"_d', desc = "Delete without yanking" },
	{ "xx", '"_dd', desc = "Delete line without yanking" },
}, { mode = "n" })

map.batch({
	{ "x", '"_d', desc = "Delete selection without yanking" },
	{ "p", '"_dP', desc = "Paste without replacing yank register" },
}, { mode = "x" })

map.t("<Esc><Esc>", [[<C-\><C-n>]], "Exit terminal mode")
