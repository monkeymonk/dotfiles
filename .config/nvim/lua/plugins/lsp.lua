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
}
