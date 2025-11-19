return {
  -- Timetrap integration for neovim
  -- https://github.com/andreadev-it/timetrap.nvim
  -- https://github.com/samg/timetrap
  {
    "andreadev-it/timetrap.nvim",
    requires = {
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("timetrap_nvim").setup({})
    end,
  },
}
