return {
  -- Vim syntax highlighting for Blade templates.
  -- @see https://github.com/smithbm2316/vim-blade
  { "smithbm2316/vim-blade" },

  -- Navigating Blade views within Laravel projects
  -- @see https://github.com/RicardoRamirezR/blade-nav.nvim
  {
    "ricardoramirezr/blade-nav.nvim",
    dependencies = {
      "hrsh7th/nvim-cmp",
    },
    ft = { "blade", "php" },
    opts = {
      close_tag_on_complete = true, -- default: true
    },
  },

  -- Best Laravel development experience with Neovim
  -- @see https://adalessa.github.io/laravel-nvim-docs/
  {
    "adalessa/laravel.nvim",
    cmd = { "Laravel" },
    config = true,
    dependencies = {
      "tpope/vim-dotenv",
      "nvim-telescope/telescope.nvim",
      "MunifTanjim/nui.nvim",
      "kevinhwang91/promise-async",
    },
    keys = {
      { "<leader>la", ":Laravel artisan<cr>" },
      { "<leader>lr", ":Laravel routes<cr>" },
      { "<leader>lm", ":Laravel related<cr>" },
    },
    event = { "VeryLazy" },
    opts = {},
  },
}
