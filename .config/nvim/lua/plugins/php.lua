return {
  -- PHP (phpcbf) auto format plugin for nvim
  -- https://github.com/yuchanns/phpfmt.nvim
  {
    "yuchanns/phpfmt.nvim",
    config = function(_, opts)
      require("phpfmt").setup(opts)
    end,
    opts = {
      auto_format = false,
      standard = "PSR2",
    },
  },
}
