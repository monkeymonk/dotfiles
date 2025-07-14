return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        cssls = {
          settings = {
            css = {
              lint = {
                unkiwnAtRule = "ignore",
              },
            },
            scss = {
              lint = {
                unkiwnAtRule = "ignore",
              },
            },
          },
        },
      },
    },
  },
  -- Garbage collector that stops inactive LSP clients to free RAM
  -- https://github.com/Zeioth/garbage-day.nvim
  {
    "zeioth/garbage-day.nvim",
    dependencies = "neovim/nvim-lspconfig",
    event = "VeryLazy",
    opts = {
      excluded_lsp_clients = {},
      notifications = true,
    },
  },

  -- Peek preview window for LSP locations in Neovim
  -- https://github.com/DNLHC/glance.nvim
  -- {
  --   "dnlhc/glance.nvim",
  --   cmd = "Glance",
  -- },

  -- A simple neovim plugin that renders diagnostics using virtual lines on top of the real line of code.
  -- https://github.com/maan2003/lsp_lines.nvim
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    config = function()
      vim.diagnostic.config({
        virtual_text = false,
      })
      require("lsp_lines").setup()
    end,
  },
}
