return {
	name = "render-markdown",
	src = "https://github.com/MeanderingProgrammer/render-markdown.nvim",
	ft = "markdown",

	setup = function()
		require("render-markdown").setup({
			file_types = { "markdown" },
			render_modes = true,
		})
	end,

	keys = function(map)
		map.n("<leader>uM", function()
			local ok, rm = pcall(require, "render-markdown")
			if ok and rm.toggle then
				rm.toggle()
			end
		end, "Toggle markdown render")
	end,
}
