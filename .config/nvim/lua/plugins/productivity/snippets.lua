local keymap = require("utils.keymap")
local bind = keymap.bind
local desc = keymap.desc

return {
  -- { import = "lazyvim.plugins.extras.coding.luasnip"},

  -- Snippet Engine for Neovim written in Lua.
  -- https://github.com/L3MON4D3/LuaSnip
  {
    "L3MON4D3/LuaSnip",
    build = "make install_jsregexp",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      {
        "rafamadriz/friendly-snippets",
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
          require("luasnip.loaders.from_lua").load({ paths = { "./snippets" } })
        end,
      },
    },
    init = function(_, opts)
      require("luasnip").setup(opts)

      vim.api.nvim_create_user_command("LuaSnipEdit", function()
        require("luasnip.loaders").edit_snippet_files()
      end, {})
    end,
    keys = {
      {
        "<leader>is",
        function()
          if require("luasnip").choice_active() then
            require("luasnip").change_choice(1)
          end
        end,
        desc = "Choose snippet",
      },
    },
    opts = {
      delete_check_events = "TextChanged",
      enable_autosnippets = true,
      history = true,
    },
    version = "2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
  },

  -- Automagical editing and creation of snippets.
  -- https://github.com/chrisgrieser/nvim-scissors
  {
    "chrisgrieser/nvim-scissors",
    dependencies = "nvim-telescope/telescope.nvim",
    keys = {
      {
        "<leader>os",
        "<cmd> lua require('scissors').editSnippet() <CR>",
        desc = "Edit snippet",
      },
      {
        "<leader>oS",
        "<cmd> lua require('scissors').addNewSnippet() <CR>",
        desc = "Add snippet",
      },
    },
    opts = {
      snippetDir = vim.fn.stdpath("data") .. "/lazy/friendly-snippets/snippets",
    },
  },

  -- Improved Yank and Put functionalities for Neovim
  {
    "gbprod/yanky.nvim",
    config = function(_, opts)
      require("yanky").setup(opts)
      require("telescope").load_extension("yank_history")

      bind("nv", "p", "<Plug>(YankyPutAfter)", desc("Paste after"))
      bind("nv", "P", "<Plug>(YankyPutBefore)", desc("Paste before"))
      bind("nv", "gp", "<Plug>(YankyGPutAfter)", desc("Yanky put after"))
      bind("nv", "gP", "<Plug>(YankyGPutBefore)", desc("Yanky put before"))
      bind("nv", "<C-n>", "<Plug>(YankyCycleForward)", desc("Yanky cycle forward"))
      bind("nv", "<C-p>", "<Plug>(YankyCycleBackward)", desc("Yanky cycle backward"))
      bind(
        "nv",
        "gH",
        "<cmd> lua require('telescope').extensions.yank_history.yank_history() <CR>",
        desc("Yanky history")
      )
    end,
    keys = {
      {
        "<leader>oh",
        "<cmd> Telescope yank_history <CR>",
        desc = "Yanky history",
      },
    },
  },
}
