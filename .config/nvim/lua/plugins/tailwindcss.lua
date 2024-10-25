return {
  -- An unofficial Tailwind CSS integration and tooling for Neovim
  -- https://github.com/luckasRanarison/tailwind-tools.nvim
  {
    "luckasRanarison/tailwind-tools.nvim",
    name = "tailwind-tools",
    build = ":UpdateRemotePlugins",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim",
      "neovim/nvim-lspconfig",
    },
  },
}
