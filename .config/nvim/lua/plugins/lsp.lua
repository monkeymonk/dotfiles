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
}
