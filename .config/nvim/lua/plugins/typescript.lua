return {
  -- TypeScript integration NeoVim deserves
  -- https://github.com/pmizio/typescript-tools.nvim
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {
      settings = {
        separate_diagnostic_server = true,
        expose_as_code_action = "all",
        tsserver_file_preferences = {
          includeInlayParameterNameHints = "all",
          includeInlayFunctionLikeReturnTypeHints = true,
        },
      },
    },
    config = function(_, opts)
      require("typescript-tools").setup(opts)

      -- 🔇 disable diagnostics from typescript-tools
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "typescript-tools" then
            client.handlers["textDocument/publishDiagnostics"] = function() end
          end
        end,
      })
    end,
  },
}
