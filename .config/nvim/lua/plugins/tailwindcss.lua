return {
  -- An unofficial Tailwind CSS integration and tooling for Neovim
  -- https://github.com/luckasRanarison/tailwind-tools.nvim
  {
    "luckasRanarison/tailwind-tools.nvim",
    build = ":UpdateRemotePlugins",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim",
      "neovim/nvim-lspconfig",
    },
    init = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "tailwindcss" then
            require("tailwind-tools")
            return true
          end
        end,
      })
    end,
    lazy = true,
    name = "tailwind-tools",
    opts = {
      conceal = {
        symbol = "…",
      },
    },
  },
}
