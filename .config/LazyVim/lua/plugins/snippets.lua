local keymap = require("utils.keymap")
local bind = keymap.bind
local desc = keymap.desc

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
  {
    "chrisgrieser/nvim-scissors",
    dependencies = { "nvim-telescope/telescope.nvim", "garymjr/nvim-snippets" },
    opts = {
      snippetDir = vim.fn.stdpath("config") .. "snippets",
    },
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
  },

  -- Improved Yank and Put functionalities for Neovim
  -- https://github.com/gbprod/yanky.nvim
  {
    "gbprod/yanky.nvim",
    dependencies = "nvim-telescope/telescope.nvim",
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
