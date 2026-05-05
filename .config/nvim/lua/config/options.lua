local opt = vim.opt
local g = vim.g

local extra_paths = {
	vim.fn.expand("~/.local/bin"),
	vim.fn.expand("~/.local/share/nvim/mason/bin"),
}
vim.env.PATH = table.concat(extra_paths, ":") .. ":" .. vim.env.PATH

opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.wrap = false
opt.linebreak = true
opt.breakindent = true
opt.scrolloff = 4
opt.sidescrolloff = 8

opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

opt.expandtab = true
opt.smarttab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.shiftround = true
opt.autoindent = true
opt.smartindent = true

opt.splitbelow = true
opt.splitright = true

opt.clipboard = "unnamedplus"
opt.completeopt = { "menuone", "popup", "noselect" }

opt.hidden = true
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("state") .. "/undo"
opt.backupskip = { "/tmp/*", "/private/tmp/*" }

opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldtext = ""
opt.foldlevel = 99
opt.foldlevelstart = 99

opt.updatetime = 200
opt.timeoutlen = 300

opt.whichwrap:append("<,>,[,],h,l")

opt.formatoptions:remove("o")
opt.formatoptions:append("rnj")

opt.exrc = true

if vim.fn.executable("rg") == 1 then
	opt.grepprg = "rg --vimgrep --smart-case --hidden"
	opt.grepformat = "%f:%l:%c:%m"
end

vim.filetype.add({
	pattern = {
		["%.*aliases.*"] = "bash",
		["%.*zprofile.*"] = "bash",
		["%.env.*"] = "dotenv",
		["%.env.*%.example"] = { "conf", { priority = 1 } },
		[".*/git/config.*"] = "git_config",
		["requirements.*%.txt"] = "requirements",
		[".*%.blade%.php"] = "blade",
		[".*%.gd"] = "gdscript",
		[".*%.gdshader"] = "gdshader",
		[".*%.tres"] = "godot_resource",
		[".*%.tscn"] = "godot_resource",
	},
})

vim.treesitter.language.register("bash", "dotenv")
vim.treesitter.language.register("gdscript", "gd")

if g.neovide then
	g.neovide_confirm_quit = true
	g.neovide_cursor_animation_length = 0
	g.neovide_cursor_trail_length = 0
	g.neovide_scale_factor = 0.8
end
