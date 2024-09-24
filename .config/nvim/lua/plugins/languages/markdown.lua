return {
  -- markdown preview plugin for (neo)vim
  -- https://github.com/iamcco/markdown-preview.nvim
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npm install",
    enabled = true,
    ft = "markdown",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
  },

  -- pandoc integration and utilities for vim
  -- https://github.com/vim-pandoc/vim-pandoc
  {
    "vim-pandoc/vim-pandoc",
    dependencies = {
      "vim-pandoc/vim-pandoc-syntax",
      lazy = true,
    },
    -- init = function()
    --   vim.g.pandoc_filetypes_handled = { "pandoc", "markdown" }
    --   vim.g.pandoc_filetypes_pandoc_markdown = 0
    -- end,
    -- keys = {
    --   "<leader>nP",
    --   "<cmd>Pandoc revealjs -s --mathjax -i<CR>", -- "--include-in-header=style.css -V theme=white"
    --   desc = "Generate Presentation",
    --   mode = "n",
    -- },
  },

  -- A neovim plugin leveraging pandoc to help you convert your markdown files. It takes pandoc options from yaml blocks.
  -- https://github.com/jghauser/auto-pandoc.nvim
  {
    "jghauser/auto-pandoc.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    ft = "markdown",
  },

  -- TODO: check https://mfontanini.github.io/presenterm/

  -- Slides presentation in your Neovim
  -- https://github.com/aspeddro/slides.nvim
  -- NOTE: use `chafa` to display images (see https://github.com/maaslalani/slides/issues/2#issuecomment-1751728049)
  {
    "aspeddro/slides.nvim",
    config = function(_, opts)
      require("slides").setup(opts)
    end,
    opts = {},
  },
}
