return {
  -- All the npm/yarn/pnpm commands I don't want to type
  -- https://github.com/vuki656/package-info.nvim
  {
    "vuki656/package-info.nvim",
    config = function(_, opts)
      require("package-info").setup(opts)

      vim.cmd([[highlight PackageInfoUpToDateVersion guifg=]] .. opts.colors.up_to_date)
      vim.cmd([[highlight PackageInfoOutdatedVersion guifg=]] .. opts.colors.outdated)

      local telescope = require("telescope")

      telescope.setup({
        extensions = {
          package_info = {
            -- Optional theme (the extension doesn't set a default theme)
            theme = "ivy",
          },
        },
      })

      telescope.load_extension("package_info")
    end,
    dependencies = "MunifTanjim/nui.nvim",
    event = "VeryLazy",
    ft = "json",
    keys = {
      { "<leader>rS", "<cmd> lua require('package-info').show() <CR>", desc = "Show dependencies latest version" },
      { "<leader>rs", "<cmd> lua require('package-info').toggle() <CR>", desc = "Toggle dependency versions" },
      { "<leader>ra", "<cmd> lua require('package-info').install() <CR>", desc = "Install a new dependency" },
      {
        "<leader>ru",
        "<cmd> lua require('package-info').change_version() <CR>",
        desc = "Install a different dependency version",
      },
    },
    opts = {
      colors = {
        outdated = "#d19a66",
        up_to_date = "#0DB9D7",
      },
      hide_unstable_versions = true,
      package_manager = "npm",
    },
  },
}
