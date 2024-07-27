local keymap = require("utils.keymap")
local bind = keymap.bind
local desc = keymap.desc

return {
  -- A neovim lua plugin to help easily manage multiple terminal windows
  -- https://github.com/akinsho/toggleterm.nvim
  {
    "akinsho/toggleterm.nvim",
    config = function(_, opts)
      require("toggleterm").setup(opts)

      bind("nv", "<leader>ot", "<cmd> ToggleTerm direction=horizontal <CR>", desc("Open bottom terminal"))
      bind("nv", "<leader>oT", "<cmd> ToggleTerm direction=float <CR>", desc("Open float terminal"))
    end,
    event = "VeryLazy",
    opts = { size = 16 },
    version = "*",
  },

  -- Seamless navigation between tmux panes and vim splits
  -- https://github.com/christoomey/vim-tmux-navigator
  {
    "christoomey/vim-tmux-navigator",
    config = function()
      bind("n", "<C-Left>", "<cmd>TmuxNavigateLeft<CR>", desc("window left"))
      bind("n", "<C-Right>", "<cmd>TmuxNavigateRight<CR>", desc("window right"))
      bind("n", "<C-Down>", "<cmd>TmuxNavigateDown<CR>", desc("window down"))
      bind("n", "<C-Up>", "<cmd>TmuxNavigateUp<CR>", desc("window up"))
    end,
    event = "VeryLazy",
  },

  -- Embed your vim statusline in tmux
  -- https://github.com/vimpostor/vim-tpipeline
  -- {
  --   "vimpostor/vim-tpipeline",
  -- },
}
