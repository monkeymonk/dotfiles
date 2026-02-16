return {
  -- https://github.com/gisketch/triforce.nvim
  {
    "gisketch/triforce.nvim",
    dependencies = {
      "nvzone/volt",
    },
    config = function()
      require("triforce").setup({
        keymap = {
          show_profile = "<leader>qt",
        },
      })
    end,
  },
}
