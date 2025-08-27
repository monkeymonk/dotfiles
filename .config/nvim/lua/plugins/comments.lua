return {
  -- Create annotations with one keybind, and jump your cursor in the inserted annotation
  -- https://github.com/danymat/neogen
  {
    "danymat/neogen",
    config = true,
    dependencies = "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    keys = {
      {
        "gcC",
        function()
          require("neogen").generate({})
        end,
        desc = "Neogen Comment",
      },
      {
        "gC",
        function()
          require("neogen").generate({})
        end,
        desc = "Neogen Comment",
        mode = "v",
      },
    },
    opts = {
      languages = { php = { template = { annotation_convention = "phpdoc" } } },
      snippet_engine = "luasnip",
    },
  },

  -- Smart and powerful comment plugin for neovim. Supports treesitter, dot repeat, left-right/up-down motions, hooks, and more
  -- https://github.com/numToStr/Comment.nvim
  {
    "numToStr/Comment.nvim",
    dependencies = "JoosepAlviste/nvim-ts-context-commentstring",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
    },
  },
}
