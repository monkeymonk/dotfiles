return {
  -- Portable package manager for Neovim that runs everywhere Neovim runs. Easily install and manage LSP servers, DAP servers, linters, and formatters.
  -- https://github.com/mason-org/mason.nvim
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "actionlint",
        "ansible-language-server",
        "ansible-lint",
        "antlers-language-server",
        "black",
        "bash-language-server",
        "blade-formatter",
        "css-lsp",
        "docker-compose-language-service",
        "dockerfile-language-server",
        "dot-language-server",
        "efm",
        "emmet-ls",
        "eslint_d",
        "flake8",
        "hadolint",
        "html-lsp",
        "intelephense",
        "ltex-ls",
        "luacheck",
        "nginx-language-server",
        "php-debug-adapter",
        "phpstan",
        "pint",
        "prettierd",
        "pyright",
        "rustywind",
        "selene",
        "shellcheck",
        "shfmt",
        "stylua",
        "tailwindcss-language-server",
        "typescript-language-server",
        "vue-language-server",
      },
      handlers = {
        function(config)
          -- all sources with no handler get passed here

          -- Keep original functionality
          require("mason-nvim-dap").default_setup(config)
        end,
        php = function(config)
          config.configurations = {
            {
              type = "php",
              request = "launch",
              name = "Listen for Xdebug",
              port = 9003,
              pathMappings = {
                -- For some reason xdebug sometimes fails for me, depending on me
                -- using herd or docker. To get it to work, change the order of the mappings.
                -- The first mapping should be the one that you are actively using.
                -- This only started recently, so I don't know what changed.
                ["${workspaceFolder}"] = "${workspaceFolder}",
                ["/var/www/html"] = "${workspaceFolder}",
              },
            },
          }
          require("mason-nvim-dap").default_setup(config) -- don't forget this!
        end,
      },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
    },
    opts = {
      automatic_enable = true,
    },
  },
}
