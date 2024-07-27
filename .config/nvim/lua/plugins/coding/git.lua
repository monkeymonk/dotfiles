local keymap = require("utils.keymap")
local bind = keymap.bind
local desc = keymap.desc

return {
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
      {
        "<leader>tb",
        "<cmd> Gitsigns toggle_current_line_blame <CR>",
        desc = "Toggle line blame",
        mode = { "n", "v" },
      },
    },
  },

  -- https://github.com/aaronhallaert/advanced-git-search.nvim
  {
    "aaronhallaert/advanced-git-search.nvim",
    config = function()
      require("telescope").load_extension("advanced_git_search")

      bind("nv", "<leader>gB", "<cmd> Telescope advanced_git_search diff_branch_file <CR>", desc("Search branches"))
      bind(
        "nv",
        "<leader>gL",
        "<cmd> Telescope advanced_git_search search_log_content <CR>",
        desc("Search previous commits")
      )
      bind(
        "nv",
        "<leader>gD",
        "<cmd> Telescope advanced_git_search diff_commit_file <CR>",
        desc("Search previous commits in file")
      )
      bind("nv", "<leader>gs", "<cmd> Telescope advanced_git_search checkout_reflog <CR>", desc("Search reflog"))
    end,
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "tpope/vim-fugitive",
      "tpope/vim-rhubarb",
    },
  },

  -- https://github.com/airblade/vim-gitgutter
  { "airblade/vim-gitgutter", event = { "BufReadPre", "BufNewFile" } },

  -- https://github.com/emmanueltouzery/agitator.nvim
  {
    "emmanueltouzery/agitator.nvim",
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

  -- https://github.com/NeogitOrg/neogit
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    keys = {
      {
        "<leader>gg",
        "<cmd> Neogit <CR>",
        desc = "Neogit status",
        mode = { "n", "v" },
      },
      { "<leader>go", "<cmd> Telescope git_status <CR>", desc = "Open changed file", mode = { "n", "v" } },
      { "<leader>gb", "<cmd> Telescope git_branches <CR>", desc = "Checkout branch", mode = { "n", "v" } },
      { "<leader>gc", "<cmd> Telescope git_commits <CR>", desc = "Checkout commit", mode = { "n", "v" } },
      {
        "<leader>gC",
        "<cmd> Telescope git_bcommits <CR>",
        desc = "Checkout commit(for current file)",
        mode = { "n", "v" },
      },
    },
    opts = {
      integrations = {
        telescope = true,
      },
      use_magit_keybindings = false,
    },
    version = "0.0.1",
  },

  -- A plugin to visualise and resolve merge conflicts in neovim
  -- https://github.com/akinsho/git-conflict.nvim
  {
    "akinsho/git-conflict.nvim",
    config = function(_, opts)
      require("git-conflict").setup(opts)

      -- utils.autocmd("User", function()
      --   vim.notify("Conflict detected in " .. vim.fn.expand("<afile>"))
      -- end, {
      --   pattern = "GitConflictDetected",
      -- })
    end,
    keys = {
      "<leader>gQ",
      "<cmd> GitConflictListQf <CR>",
      desc = "Get all conflict to quickfix",
      mode = { "n", "v" },
    },
    opts = {
      default_mappings = {
        both = "b",
        next = "n",
        none = "0",
        ours = "o",
        prev = "p",
        theirs = "t",
      },
    },
    version = "*",
  },
}
