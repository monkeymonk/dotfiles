return {
  -- Vim syntax highlighting for Blade templates.
  -- https://github.com/jwalton512/vim-blade
  {
    "jwalton512/vim-blade",
    ft = { "blade", "php" },
  },

  -- Navigating Blade views within Laravel projects
  -- https://github.com/RicardoRamirezR/blade-nav.nvim
  {
    "ricardoramirezr/blade-nav.nvim",
    dependencies = "hrsh7th/nvim-cmp",
    ft = { "blade", "php" },
    opts = {
      close_tag_on_complete = true, -- default: true
    },
  },

  -- Best Laravel development experience with Neovim
  -- https://adalessa.github.io/laravel-nvim-docs/
  {
    "adalessa/laravel.nvim",
    cmd = "Laravel",
    config = true,
    dependencies = {
      "tpope/vim-dotenv",
      "nvim-telescope/telescope.nvim",
      "MunifTanjim/nui.nvim",
      "kevinhwang91/promise-async",
    },
    ft = { "blade", "php" },
    keys = {
      { "<leader>ola", ":Laravel artisan<cr>" },
      { "<leader>olr", ":Laravel routes<cr>" },
      { "<leader>olm", ":Laravel related<cr>" },
    },
  },

  -- Quickstart configs for Nvim LSP
  -- https://github.com/neovim/nvim-lspconfig
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = true },
      -- @type lspconfig.options
      servers = {
        intelephense = {
          filetypes = { "php", "blade", "php_only" },
          settings = {
            intelephense = {
              filetypes = { "php", "blade", "php_only" },
              files = {
                associations = { "*.php", "*.blade.php" }, -- Associating .blade.php files as well
                maxSize = 5000000,
              },
              stubs = { "psr-4" },
            },
          },
        },
        phpactor = {
          filetypes = { "blade", "php" },
          settings = {
            phpactor = {
              filetypes = { "blade", "php" },
              files = {
                associations = { "*.php", "*.blade.php" },
                maxSize = 5000000,
              },
            },
          },
          --[[ phpstan = {
            enabled = false,
          },
          psalm = {
            enabled = false,
          }, ]]
        },
      },
    },

    -- @TODO: add blade parser
    --[[ {
      "nvim-treesitter/nvim-treesitter",
      config = function()
        local parser_config = require("nvim-treesitter.parsers").get_parser_configs()

        parser_config.blade = {
          filetype = "blade",
          install_info = {
            branch = "main",
            files = { "src/parser.c" },
            url = "https://github.com/EmranMR/tree-sitter-blade",
          },
        }

        vim.filetype.add({
          pattern = {
            [".*%.blade%.php"] = "blade",
          },
        })
      end,
      opts = {
        ensure_installed = { "blade", "php" },
      },
    }, ]]
  },
}
