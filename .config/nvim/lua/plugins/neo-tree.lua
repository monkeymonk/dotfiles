return {
  -- This plugins prompts the user to pick a window and returns the window id of the picked window
  -- https://github.com/s1n7ax/nvim-window-picker
  {
    "s1n7ax/nvim-window-picker",
    config = function(_, opts)
      require("window-picker").setup(opts)
    end,
    event = "VeryLazy",
    name = "window-picker",
    opts = {
      filter_rules = {
        autoselect_one = true,
        -- filter using buffer options
        bo = {
          -- if the buffer type is one of following, the window will be ignored
          buftype = { "jumplist", "quickfix", "terminal" },
          -- if the file type is one of following, the window will be ignored
          filetype = { "neo-tree", "neo-tree-popup", "NvimTree", "notify", "snacks_notif" },
        },
        include_current_win = false,
      },
      hint = "floating-big-letter",
      picker_config = {
        floating_big_letter = {
          font = "ansi-shadow",
          -- Note: Custom font can be defined here if needed
          -- See: https://github.com/s1n7ax/nvim-window-picker/blob/main/lua/window-picker/hints/data/ansi-shadow.lua
        },
      },
    },
    version = "2.*",
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = "s1n7ax/nvim-window-picker",
    opts = {
      window = {
        mappings = {
          ["<CR>"] = "open_with_window_picker",
          ["w"] = "open_with_window_picker",
        },
      },
    },
  },
}
