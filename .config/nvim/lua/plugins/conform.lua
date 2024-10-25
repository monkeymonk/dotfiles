return {
  -- Lightweight yet powerful formatter plugin for Neovim
  -- https://github.com/stevearc/conform.nvim
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = function()
      local util = require("conform.util")

      ---@type conform.setupOpts
      return {
        default_format_opts = {
          timeout_ms = 3000,
          async = false, -- not recommended to change
          quiet = false, -- not recommended to change
          lsp_format = "fallback", -- not recommended to change
        },
        formatters_by_ft = {
          blade = { "blade-formatter", "rustywind" },
          css = { "stylelint", "prettier" },
          fish = { "fish_indent" },
          go = { "gofumpt", "golines" },
          javascript = { "prettier", "eslint" },
          json = { "prettier" },
          lua = { "stylua" },
          php = { "pint" },
          python = { "isort", "black" },
          rust = { "rustfmt" },
          sh = { "shfmt" },
          sql = { "sqlfluff" },
          yaml = { "yamlfmt" },
          zig = { "zigfmt" },
        },
        -- LazyVim will merge the options you set here with builtin formatters.
        -- You can also define any custom formatters here.
        ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
        formatters = {
          injected = { options = { ignore_errors = true } },
          -- # Example of using dprint only when a dprint.json file is present
          -- dprint = {
          --   condition = function(ctx)
          --     return vim.fs.find({ "dprint.json" }, { path = ctx.filename, upward = true })[1]
          --   end,
          -- },
          --
          -- # Example of using shfmt with extra args
          -- shfmt = {
          --   extra_args = { "-i", "2", "-ci" },
          -- },
          pint = {
            meta = {
              url = "https://github.com/laravel/pint",
              description = "Laravel Pint is an opinionated PHP code style fixer for minimalists. Pint is built on top of PHP-CS-Fixer and makes it simple to ensure that your code style stays clean and consistent.",
            },
            command = util.find_executable({
              vim.fn.stdpath("data") .. "/mason/bin/pint",
              "vendor/bin/pint",
            }, "pint"),
            args = { "$FILENAME" },
            stdin = false,
          },
          sqlfluff = {
            command = "sqlfluff",
            args = {
              "fix",
              "--dialect",
              "postgres",
              "--disable-progress-bar",
              "-f",
              "-n",
              "-",
            },
            stdin = true,
          },
        },
      }
    end,
  },
}
