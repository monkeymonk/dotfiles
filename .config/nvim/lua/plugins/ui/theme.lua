return {
  -- Soothing pastel theme for (Neo)vim
  -- https://github.com/catppuccin/nvim
  {
    "catppuccin/nvim",
    config = function(_, opts)
      require("catppuccin").setup(opts)

      vim.cmd([[colorscheme catppuccin]])
    end,
    name = "catppuccin",
    opts = {
      flavour = "mocha",
      integrations = {
        alpha = true,
        cmp = true,
        coc_nvim = true,
        dap = {
          enabled = true,
          enable_ui = true,
        },
        dashboard = true,
        gitsigns = true,
        lsp_saga = true,
        lsp_trouble = true,
        markdown = true,
        mason = true,
        mini = true,
        neogit = true,
        noice = true,
        notify = true,
        nvimtree = true,
        symbols_outline = true,
        telescope = true,
        treesitter = true,
        treesitter_context = true,
        which_key = true,
      },
    },
    priority = 1000, -- make sure to load this before all the other start plugins
  },

  -- lua `fork` of vim-web-devicons for neovim
  -- https://github.com/nvim-tree/nvim-web-devicons
  { "nvim-tree/nvim-web-devicons", lazy = true },
}
