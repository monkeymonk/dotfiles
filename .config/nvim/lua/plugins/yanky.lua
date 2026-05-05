return {
	name = "yanky",
	src = "https://github.com/gbprod/yanky.nvim",
	dependencies = {
		"https://github.com/folke/snacks.nvim",
	},
	priority = 110,

	opts = {
		ring = {
			history_length = 100,
			storage = "shada",
			sync_with_numbered_registers = true,
			ignore_registers = { "_" },
		},
		system_clipboard = {
			sync_with_ring = true,
		},
		highlight = {
			on_put = true,
			on_yank = true,
			timer = 300,
		},
		preserve_cursor_position = {
			enabled = true,
		},
		textobj = {
			enabled = true,
		},
	},

	keys = function(map)
		map.map({ "n", "x" }, "y", "<Plug>(YankyYank)", "Yank")
		map.map({ "n", "x" }, "p", "<Plug>(YankyPutAfter)", "Put after")
		map.map({ "n", "x" }, "P", "<Plug>(YankyPutBefore)", "Put before")
		map.map({ "n", "x" }, "gp", "<Plug>(YankyGPutAfter)", "Put after and leave cursor")
		map.map({ "n", "x" }, "gP", "<Plug>(YankyGPutBefore)", "Put before and leave cursor")
		map.n("]p", "<Plug>(YankyPutIndentAfterLinewise)", "Put linewise below")
		map.n("[p", "<Plug>(YankyPutIndentBeforeLinewise)", "Put linewise above")
		map.n("]P", "<Plug>(YankyPutIndentAfterLinewise)", "Put linewise below")
		map.n("[P", "<Plug>(YankyPutIndentBeforeLinewise)", "Put linewise above")
		map.n(">p", "<Plug>(YankyPutIndentAfterShiftRight)", "Put and indent right")
		map.n("<p", "<Plug>(YankyPutIndentAfterShiftLeft)", "Put and indent left")
		map.n(">P", "<Plug>(YankyPutIndentBeforeShiftRight)", "Put before and indent right")
		map.n("<P", "<Plug>(YankyPutIndentBeforeShiftLeft)", "Put before and indent left")
		map.n("=p", "<Plug>(YankyPutAfterFilter)", "Put after and filter")
		map.n("=P", "<Plug>(YankyPutBeforeFilter)", "Put before and filter")
		map.map({ "n", "x" }, "<leader>y", function()
			local ok, snacks = pcall(require, "snacks")
			if ok and snacks.picker and snacks.picker.yanky then
				snacks.picker.yanky()
			else
				vim.cmd("YankyRingHistory")
			end
		end, "Yank history")
		map.map({ "o", "x" }, "iy", function()
			require("yanky.textobj").last_put()
		end, "Last put text object")
	end,
}
