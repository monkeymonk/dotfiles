local map = require("util.map")

map.batch({
	{ "Q", "<Nop>", desc = "Disable Ex mode" },
	{ "<S-l>", "<cmd>bnext<cr>", desc = "Next buffer" },
	{ "<S-h>", "<cmd>bprevious<cr>", desc = "Previous buffer" },
	{ "+", "<C-a>", desc = "Increment number" },
	{ "-", "<C-x>", desc = "Decrement number" },
	{ "<Esc>", "<cmd>nohlsearch<cr>", desc = "Clear search highlight" },
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
	{ "x", '"_x', desc = "Delete char without yanking" },
}, { mode = { "n", "x" } })

map.batch({
	{ "<leader>d", '"_d', desc = "Delete without yanking" },
	{ "p", '"_dP', desc = "Paste without replacing yank register" },
}, { mode = "x" })

map.n("<leader>d", '"_d', "Delete without yanking")
map.t("<Esc><Esc>", [[<C-\><C-n>]], "Exit terminal mode")
