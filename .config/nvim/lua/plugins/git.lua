return {
  -- An interactive and powerful Git interface for Neovim, inspired by Magit
  -- https://github.com/NeogitOrg/neogit
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = true,
    event = "VeryLazy",
    keys = {
      {
        "<leader>gg",
        "<cmd> Neogit <CR>",
        desc = "Neogit status",
        mode = { "n", "v" },
      },
      { "<leader>go", "<cmd> FzfLua git_status <CR>", desc = "Find in changed file", mode = { "n", "v" } },
      -- { "<leader>gb", "<cmd> Telescope git_branches <CR>", desc = "Checkout branch", mode = { "n", "v" } },
      -- { "<leader>gc", "<cmd> Telescope git_commits <CR>", desc = "Checkout commit", mode = { "n", "v" } },
      {
        "<leader>gC",
        "<cmd> FzfLua git_bcommits <CR>",
        desc = "Checkout commit(for current file)",
        mode = { "n", "v" },
      },
    },
  },

  -- Git integration for buffers
  -- https://github.com/lewis6991/gitsigns.nvim
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    keys = {
      {
        "<leader>gi",
        "<cmd> Gitsigns toggle_current_line_blame <CR>",
        desc = "Toggle line blame",
        mode = { "n", "v" },
      },
      -- {
      --   "<leader>gj",
      --   "<cmd> lua require('gitsigns').next_hunk({ navigation_message = false }) <CR>",
      --   desc = "Next hunk",
      --   mode = { "n", "v" },
      -- },
      -- {
      --   "<leader>gk",
      --   "<cmd> lua require('gitsigns').prev_hunk({ navigation_message = false }) <CR>",
      --   desc = "Prev hunk",
      --   mode = { "n", "v" },
      -- },
      { "<leader>gd", "<cmd> Gitsigns diffthis HEAD <CR>", desc = "Git Diff", mode = { "n", "v" } },
    },
  },

  -- Search your git history by commit message, content and author in Neovim
  -- https://github.com/aaronhallaert/advanced-git-search.nvim
  {
    "aaronhallaert/advanced-git-search.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "tpope/vim-fugitive",
      "tpope/vim-rhubarb",
    },
    config = function()
      require("telescope").load_extension("advanced_git_search")
    end,
    event = "VeryLazy",
    keys = {
      {
        "<leader>gB",
        "<cmd> Telescope advanced_git_search diff_branch_file <CR>",
        desc = "Search branches",
        mode = { "n", "v" },
      },
      -- {
      --   "<leader>gL",
      --   "<cmd> Telescope advanced_git_search search_log_content <CR>",
      --   desc = "Search previous commits",
      --   mode = { "n", "v" },
      -- },
      {
        "<leader>gD",
        "<cmd> Telescope advanced_git_search diff_commit_file <CR>",
        desc = "Search previous commits in file",
        mode = { "n", "v" },
      },
      -- {
      --   "<leader>gs",
      --   "<cmd> Telescope advanced_git_search checkout_reflog <CR>",
      --   desc = "Search reflog",
      --   mode = { "n", "v" },
      -- },
    },
  },

  -- agitator is a neovim/lua plugin providing some git-related functions:
  -- https://github.com/emmanueltouzery/agitator.nvim
  {
    "emmanueltouzery/agitator.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<leader>gt",
        "<cmd> lua require('agitator').git_time_machine({ use_current_win = false }) <CR>",
        desc = "Time machine",
        mode = { "n", "v" },
      },
      { "<leader>gl", "<cmd> lua require('agitator').git_blame_toggle() <CR>", desc = "Blame", mode = { "n", "v" } },
    },
  },

  -- A plugin to visualise and resolve merge conflicts in neovim
  -- https://github.com/akinsho/git-conflict.nvim
  {
    "akinsho/git-conflict.nvim",
    config = true,
    event = "VeryLazy",
    version = "*",
  },
}
