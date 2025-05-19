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

  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      -- opts.formatters_by_ft.php = { "php_cs_fixer" }

      --[[ local util = require("conform.util")

      opts.formatters_by_ft.php = { "pint" }
      opts.formatters.pint = {
        pint = {
          meta = {
            description = "Laravel Pint is an opinionated PHP code style fixer for minimalists. Pint is built on top of PHP-CS-Fixer and makes it simple to ensure that your code style stays clean and consistent.",
            url = "https://github.com/laravel/pint",
          },
          command = util.find_executable({
            vim.fn.stdpath("data") .. "/mason/bin/pint",
            "vendor/bin/pint",
          }, "pint"),
          args = { "$FILENAME" },
          stdin = false,
        },
      } ]]
    end,
  },
}
