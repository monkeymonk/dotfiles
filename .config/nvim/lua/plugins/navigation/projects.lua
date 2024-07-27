return {
  -- Simple session management for Neovim
  -- https://github.com/folke/persistence.nvim
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    keys = {
      {
        "<leader>qs",
        function()
          require("persistence").save()
          require("notify")("Session saved!", "success", { title = "folke/persistence.nvim" })
        end,
        desc = "Save Session",
      },
      {
        "<leader>ql",
        function()
          require("persistence").load()
          require("notify")("Session restored!", "success", { title = "folke/persistence.nvim" })
        end,
        desc = "Restore Session",
      },
      {
        "<leader>qL",
        function()
          require("persistence").load({ last = true })
          require("notify")("Session restored!", "success", { title = "folke/persistence.nvim" })
        end,
        desc = "Restore Last Session",
      },
      {
        "<leader>qS",
        function()
          require("persistence").stop()
          require("notify")("Session auto-save stopped!", "success", { title = "folke/persistence.nvim" })
        end,
        desc = "Stop Session Auto Save",
      },
    },
    opts = {
      -- options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp" },
      options = vim.opt.sessionoptions:get(),
    },
  },
}
