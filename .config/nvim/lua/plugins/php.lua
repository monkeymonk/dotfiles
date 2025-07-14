local stubs = require("config.php_stubs")
stubs.ensure_php_stubs()

return {
  -- PHP (phpcbf) auto format plugin for nvim
  -- https://github.com/yuchanns/phpfmt.nvim
  --[[ {
    "yuchanns/phpfmt.nvim",
    config = function(_, opts)
      require("phpfmt").setup(opts)
    end,
    opts = {
      auto_format = false,
      standard = "PSR2",
    },
  }, ]]

  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = { "phpcs", "php-cs-fixer", "prettierd" },
    },
  },

  -- Quickstart configs for Nvim LSP
  -- https://github.com/neovim/nvim-lspconfig
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- intelephense = {
        --   filetypes = { "php", "blade", "php_only" },
        --   settings = {
        --     intelephense = {
        --       environment = {
        --         includePaths = stubs.get_stub_paths(),
        --       },
        --       files = {
        --         associations = { "*.php", "*.blade.php" }, -- Associating .blade.php files as well
        --         maxSize = 5000000,
        --       },
        --       stubs = {
        --         "wordpress",
        --         "woocommerce",
        --         "acf-pro",
        --         "php",
        --         "bcmath",
        --         "Core",
        --         "curl",
        --         "date",
        --         "json",
        --         "mbstring",
        --         "pcre",
        --         "spl",
        --         "standard",
        --         "superglobals",
        --         "xml",
        --       },
        --     },
        --   },
        -- },
        phpactor = false,
        -- phpactor = {
        --   filetypes = { "php", "blade" },
        --   root_dir = function(fname)
        --     local util = require("lspconfig.util")
        --     return util.root_pattern("composer.json", ".git")(fname)
        --   end,
        --   settings = {
        --     phpactor = {
        --       filetypes = { "php", "blade" },
        --       language_server_phpstan = {
        --         enabled = false,
        --       },
        --       language_server_psalm = {
        --         enabled = false,
        --       },
        --       worse_reflection = {
        --         stub_paths = stubs.get_stub_paths(), -- must return an array of paths
        --       },
        --     },
        --   },
        -- },
      },
    },
  },

  -- {
  --   "stevearc/conform.nvim",
  --   optional = true,
  --   opts = function(_, opts)
  --     -- opts.formatters_by_ft.php = { "php_cs_fixer" }
  --
  --     --[[ local util = require("conform.util")
  --
  --     opts.formatters_by_ft.php = { "pint" }
  --     opts.formatters.pint = {
  --       pint = {
  --         meta = {
  --           description = "Laravel Pint is an opinionated PHP code style fixer for minimalists. Pint is built on top of PHP-CS-Fixer and makes it simple to ensure that your code style stays clean and consistent.",
  --           url = "https://github.com/laravel/pint",
  --         },
  --         command = util.find_executable({
  --           vim.fn.stdpath("data") .. "/mason/bin/pint",
  --           "vendor/bin/pint",
  --         }, "pint"),
  --         args = { "$FILENAME" },
  --         stdin = false,
  --       },
  --     } ]]
  --   end,
  -- },
}
