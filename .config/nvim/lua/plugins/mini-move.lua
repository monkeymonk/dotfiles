return {
	name = "mini-move",
	src = "https://github.com/echasnovski/mini.move",
	event = { "BufReadPost", "BufNewFile" },

	opts = {
		mappings = {
			left = "<M-h>",
			right = "<M-l>",
			down = "<M-j>",
			up = "<M-k>",
			line_left = "<M-h>",
			line_right = "<M-l>",
			line_down = "<M-j>",
			line_up = "<M-k>",
		},
	},
}
