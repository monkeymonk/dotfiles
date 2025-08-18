return {
  -- Lightweight yet powerful formatter plugin for Neovim
  -- https://github.com/stevearc/conform.nvim
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = {
      formatters_by_ft = {
        -- ["*"] = { "codespell" },
        ["_"] = { "trim_whitespace" },
        css = { "stylelint", "prettier" },
        go = { "gofumpt", "golines" },
        javascript = { "prettier" },
        json = { "prettier" },
        lua = { "stylua" },
        php = { "php_cs_fixer" },
        python = { "isort", "black" },
        rust = { "rustfmt" },
        sh = { "shfmt" },
        typescript = { "prettier" },
        yaml = { "yamlfmt" },
      },
      notify_on_error = true,
    },
    --   -- LazyVim will merge the options you set here with builtin formatters.
    --   -- You can also define any custom formatters here.
    --   ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
    --   opts.formatters = {
    --     injected = { options = { ignore_errors = true } },
    --     -- # Example of using dprint only when a dprint.json file is present
    --     -- dprint = {
    --     --   condition = function(ctx)
    --     --     return vim.fs.find({ "dprint.json" }, { path = ctx.filename, upward = true })[1]
    --     --   end,
    --     -- },
    --     --
    --     -- # Example of using shfmt with extra args
    --     -- shfmt = {
    --     --   extra_args = { "-i", "2", "-ci" },
    --     -- },
    --     sqlfluff = {
    --       command = "sqlfluff",
    --       args = {
    --         "fix",
    --         "--dialect",
    --         "postgres",
    --         "--disable-progress-bar",
    --         "-f",
    --         "-n",
    --         "-",
    --       },
    --       stdin = true,
    --     },
    --   }
    --
    --   ---@type conform.setupOpts
    --   return opts
    -- end,
  },
}
