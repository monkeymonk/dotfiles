return {
  -- Spooky scary skeletons
  -- https://github.com/Futarimiti/spooky.nvim
  {
    "Futarimiti/spooky.nvim",
    config = function(_, opts)
      require("spooky").setup(opts)
    end,
    dependencies = "nvim-telescope/telescope.nvim",
    opts = {
      ui = {
        select = "telescope",
      },
    },
  },
}
