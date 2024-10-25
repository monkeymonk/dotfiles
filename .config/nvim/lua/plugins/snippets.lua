return {
  -- Snippet Engine for Neovim written in Lua.
  -- https://github.com/L3MON4D3/LuaSnip
  {
    "L3MON4D3/LuaSnip",
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load({
        paths = { vim.fn.stdpath("config") .. "snippets" },
      })
    end,
  },

  -- Automagical editing and creation of snippets.
  -- https://github.com/chrisgrieser/nvim-scissors
  -- https://code.visualstudio.com/docs/editor/userdefinedsnippets
  -- https://code.visualstudio.com/api/language-extensions/snippet-guide
  -- https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md#vs-code
  {
    "chrisgrieser/nvim-scissors",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      {
        "garymjr/nvim-snippets",
        opts = {
          search_paths = { vim.fn.stdpath("config") .. "snippets" },
        },
      },
      {
        "neovim/nvim-lspconfig",
        opts = {
          settings = {
            snippet = {
              enable = true,
              source = vim.fn.stdpath("config") .. "snippets",
            },
          },
        },
      },
    },
    event = "VeryLazy",
    keys = {
      {
        "<leader>ose",
        "<cmd> lua require('scissors').editSnippet() <CR>",
        desc = "Edit snippet",
      },
      {
        "<leader>oss",
        "<cmd> lua require('scissors').addNewSnippet() <CR>",
        desc = "Add snippet",
      },
    },
    opts = {
      jsonFormatter = "jq",
      snippetDir = vim.fn.stdpath("config") .. "snippets",
    },
  },

  -- Improved Yank and Put functionalities for Neovim
  -- https://github.com/gbprod/yanky.nvim
  {
    "gbprod/yanky.nvim",
    dependencies = "nvim-telescope/telescope.nvim",
    config = function(_, opts)
      require("yanky").setup(opts)
      require("telescope").load_extension("yank_history")
    end,
    keys = {
      {
        "<leader>oh",
        "<cmd> Telescope yank_history <CR>",
        desc = "Yanky history",
      },
      {
        "p",
        "<Plug>(YankyPutAfter)",
        desc = "Paste after",
      },
      {
        "P",
        "<Plug>(YankyPutBefore)",
        desc = "Paste before",
      },
      {
        "gp",
        "<Plug>(YankyGPutAfter)",
        desc = "Yanky put after",
      },
      {
        "gP",
        "<Plug>(YankyGPutBefore)",
        desc = "Yanky put before",
      },
      {
        "<C-n>",
        "<Plug>(YankyCycleForward)",
        desc = "Yanky cycle forward",
      },
      {
        "<C-p>",
        "<Plug>(YankyCycleBackward)",
        desc = "Yanky cycle backward",
      },
      {
        "gH",
        "<cmd> lua require('telescope').extensions.yank_history.yank_history() <CR>",
        desc = "Yanky history",
      },
    },
  },
}
