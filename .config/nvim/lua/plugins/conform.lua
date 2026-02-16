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
        markdown = { "prettier" },
        php = { "php_cs_fixer" },
        python = { "isort", "black" },
        rust = { "rustfmt" },
        sh = { "shfmt" },
        typescript = { "prettier" },
        yaml = { "yamlfmt" },
      },
      notify_on_error = true,
    },
    -- Note: Custom formatters can be defined in opts.formatters if needed
    -- See: https://github.com/stevearc/conform.nvim#customization
  },
}
