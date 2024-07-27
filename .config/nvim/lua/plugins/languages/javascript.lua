local keymap = require("utils.keymap")
local bind = keymap.bind
local desc = keymap.desc

return {
  -- All the npm/yarn/pnpm commands I don't want to type
  {
    "vuki656/package-info.nvim",
    config = function(_, opts)
      require("package-info").setup(opts)
      require("telescope").setup({
        extensions = {
          package_info = {
            -- Optional theme (the extension doesn't set a default theme)
            theme = "ivy",
          },
        },
      })

      require("telescope").load_extension("package_info")

      bind("n", "<leader>rs", "<cmd> lua require('package-info').toggle() <CR>", desc("Toggle dependency versions"))
      bind("n", "<leader>ri", "<cmd> lua require('package-info').install() <CR>", desc("Install a new dependency"))
      bind(
        "n",
        "<leader>ru",
        "<cmd> lua require('package-info').change_version() <CR>",
        desc("Install a different dependency version")
      )
    end,
    lazy = true,
    opts = {
      hide_unstable_versions = true,
      package_manager = "npm",
    },
  },
}
