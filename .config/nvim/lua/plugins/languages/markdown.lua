return {
  -- markdown preview plugin for (neo)vim
  -- https://github.com/iamcco/markdown-preview.nvim
  {
    "iamcco/markdown-preview.nvim",
    build = " cd app && npm install",
    enabled = true,
    ft = "markdown",
  },

  -- pandoc integration and utilities for vim
  -- https://github.com/vim-pandoc/vim-pandoc
  {
    "vim-pandoc/vim-pandoc",
    dependencies = {
      "vim-pandoc/vim-pandoc-syntax",
      lazy = true,
    },
  },

  -- A neovim plugin leveraging pandoc to help you convert your markdown files. It takes pandoc options from yaml blocks.
  -- https://github.com/jghauser/auto-pandoc.nvim
  {
    "jghauser/auto-pandoc.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    ft = "markdown",
  },
}
