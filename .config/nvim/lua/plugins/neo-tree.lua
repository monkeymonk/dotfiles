return {
  -- This plugins prompts the user to pick a window and returns the window id of the picked window
  -- https://github.com/s1n7ax/nvim-window-picker
  {
    "s1n7ax/nvim-window-picker",
    config = function()
      require("window-picker").setup({
        filter_rules = {
          autoselect_one = true,
          -- filter using buffer options
          bo = {
            -- if the buffer type is one of following, the window will be ignored
            buftype = { "jumplist", "quickfix", "terminal" },
            -- if the file type is one of following, the window will be ignored
            filetype = { "neo-tree", "neo-tree-popup", "NvimTree", "notify" },
          },
          include_current_win = false,
        },
        hint = "floating-big-letter",
      })
    end,
    event = "VeryLazy",
    name = "window-picker",
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
