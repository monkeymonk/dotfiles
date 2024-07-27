-- local keymap = require("utils.keymap")
-- local bind = keymap.bind
-- local desc = keymap.desc

return {
  -- Go forward/backward with square brackets
  {
    "echasnovski/mini.bracketed",
    config = function(_, opts)
      require("mini.bracketed").setup(opts)
    end,
    event = "BufReadPost",
    opts = {
      file = { suffix = "" },
      window = { suffix = "" },
      quickfix = { suffix = "" },
      yank = { suffix = "" },
      treesitter = { suffix = "n" },
    },
  },

  -- Neovim Lua plugin with fast and feature-rich surround actions. Part of 'mini.nvim' library.
  -- https://github.com/echasnovski/mini.surround
  {
    "echasnovski/mini.surround",
    event = "BufReadPost",
    keys = function(_, keys)
      -- Populate the keys based on the user's options
      local plugin = require("lazy.core.config").spec.plugins["mini.surround"]
      local opts = require("lazy.core.plugin").values(plugin, "opts", false)
      local mappings = {
        { opts.mappings.add, desc = "Add surrounding", mode = { "n", "v" } },
        { opts.mappings.delete, desc = "Delete surrounding" },
        { opts.mappings.find, desc = "Find right surrounding" },
        { opts.mappings.find_left, desc = "Find left surrounding" },
        { opts.mappings.highlight, desc = "Highlight surrounding" },
        { opts.mappings.replace, desc = "Replace surrounding" },
        { opts.mappings.update_n_lines, desc = "Update `MiniSurround.config.n_lines`" },
      }
      mappings = vim.tbl_filter(function(m)
        return m[1] and #m[1] > 0
      end, mappings)
      return vim.list_extend(mappings, keys)
    end,
    opts = {
      mappings = {
        add = "gsa", -- Add surrounding in Normal and Visual modes
        delete = "gsd", -- Delete surrounding
        find = "gsf", -- Find surrounding (to the right)
        find_left = "gsF", -- Find surrounding (to the left)
        highlight = "gsh", -- Highlight surrounding
        replace = "gsr", -- Replace surrounding
        update_n_lines = "gsn", -- Update `n_lines`
      },
    },
  },

  -- The fastest Neovim colorizer.
  -- https://github.com/norcalli/nvim-colorizer.lua
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup()
    end,
  },

  {
    dir = "~/.config/nvim/monkeymonk/duplicate-lines",
    config = function()
      require("duplicate-lines").setup()
    end,
  },

  {
    dir = "~/.config/nvim/monkeymonk/markers",
    config = function()
      require("markers").setup()
    end,
  },
}
