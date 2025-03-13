local keymap = require("utils.keymap")
local bind = keymap.bind
local desc = keymap.desc

return {
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
    enabled = false,
    event = "VeryLazy",
  },
}
