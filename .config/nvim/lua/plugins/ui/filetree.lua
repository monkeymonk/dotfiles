local keymap = require("utils.keymap")
local bind = keymap.bind
local desc = keymap.desc

return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
      {
        "s1n7ax/nvim-window-picker",
        config = function()
          require("window-picker").setup({
            filter_rules = {
              autoselect_one = true,
              -- filter using buffer options
              bo = {
                -- if the buffer type is one of following, the window will be ignored
                buftype = { "terminal", "quickfix" },
                -- if the file type is one of following, the window will be ignored
                filetype = { "neo-tree", "neo-tree-popup", "notify" },
              },
              include_current_win = false,
            },
          })
        end,
        version = "2.*",
      },
    },
    keys = {
      { "<leader>e", false },
      { "<leader>E", false },
    },
    opts = {
      window = {
        mappings = {
          ["<CR>"] = "open_with_window_picker",
          ["w"] = "open_with_window_picker",
        },
      },
    },
  },

  -- Neovim file explorer: edit your filesystem like a buffer
  -- https://github.com/stevearc/oil.nvim
  {
    "stevearc/oil.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function(_, opts)
      require("oil").setup(opts)

      bind("n", "q", "<cmd> lua require('oil').close() <CR>", desc("Close Oil"))
      -- bind("n", "<Esc>", "<cmd> lua require('oil').close() <CR>", desc("Close Oil"))
    end,
    keys = {
      {
        "<leader>fo",
        function()
          require("oil").toggle_float(require("oil").get_current_dir())
        end,
        desc = "Toggle float oil explorer",
      },
    },
    opts = {
      columns = { "icon", "size" },
      default_file_explore = true,
      view_options = {
        show_hidden = true,
      },
    },
  },
}
