return {

  -- Git integration for buffers
  -- https://github.com/lewis6991/gitsigns.nvim
  {
    'lewis6991/gitsigns.nvim',
    -- See `:help gitsigns` to understand what the configuration keys do
    opts = {
      on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            gitsigns.nav_hunk 'next'
          end
        end, { desc = 'Jump to next git [c]hange' })

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            gitsigns.nav_hunk 'prev'
          end
        end, { desc = 'Jump to previous git [c]hange' })

        -- Actions
        -- visual mode
        map('v', '<leader>hs', function()
          gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'stage git hunk' })
        map('v', '<leader>hr', function()
          gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'reset git hunk' })
        -- normal mode
        map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'git [s]tage hunk' })
        map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'git [r]eset hunk' })
        map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'git [S]tage buffer' })
        map('n', '<leader>hu', gitsigns.undo_stage_hunk, { desc = 'git [u]ndo stage hunk' })
        map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'git [R]eset buffer' })
        map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'git [p]review hunk' })
        map('n', '<leader>hb', gitsigns.blame_line, { desc = 'git [b]lame line' })
        map('n', '<leader>hd', gitsigns.diffthis, { desc = 'git [d]iff against index' })
        map('n', '<leader>hD', function()
          gitsigns.diffthis '@'
        end, { desc = 'git [D]iff against last commit' })
        -- Toggles
        map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = '[T]oggle git show [b]lame line' })
        map('n', '<leader>tD', gitsigns.toggle_deleted, { desc = '[T]oggle git show [D]eleted' })
      end,
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },

  -- https://github.com/aaronhallaert/advanced-git-search.nvim
  {
    'aaronhallaert/advanced-git-search.nvim',
    config = function()
      require('telescope').load_extension 'advanced_git_search'

      vim.keymap.set('n', '<leader>gB', '<cmd> Telescope advanced_git_search diff_branch_file <CR>', { desc = 'Search branches' })
      vim.keymap.set('n', '<leader>gL', '<cmd> Telescope advanced_git_search search_log_content <CR>', { desc = 'Search previous commits' })
      vim.keymap.set('n', '<leader>gD', '<cmd> Telescope advanced_git_search diff_commit_file <CR>', { desc = 'Search previous commits in file' })
      vim.keymap.set('n', '<leader>gs', '<cmd> Telescope advanced_git_search checkout_reflog <CR>', { desc = 'Search reflog' })
    end,
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'tpope/vim-fugitive',
      'tpope/vim-rhubarb',
    },
  },

  -- https://github.com/airblade/vim-gitgutter
  { 'airblade/vim-gitgutter', event = { 'BufReadPre', 'BufNewFile' } },

  -- https://github.com/emmanueltouzery/agitator.nvim
  {
    'emmanueltouzery/agitator.nvim',
    keys = {
      {
        '<leader>gt',
        "<cmd> lua require('agitator').git_time_machine({ use_current_win = false }) <CR>",
        desc = 'Time machine',
        mode = { 'n', 'v' },
      },
      { '<leader>gl', "<cmd> lua require('agitator').git_blame_toggle() <CR>", desc = 'Blame', mode = { 'n', 'v' } },
    },
  },

  -- https://github.com/NeogitOrg/neogit
  {
    'NeogitOrg/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'sindrets/diffview.nvim',
      'nvim-telescope/telescope.nvim',
    },
    keys = {
      {
        '<leader>gg',
        '<cmd> Neogit <CR>',
        desc = 'Neogit status',
        mode = { 'n', 'v' },
      },
      { '<leader>go', '<cmd> Telescope git_status <CR>', desc = 'Open changed file', mode = { 'n', 'v' } },
      { '<leader>gb', '<cmd> Telescope git_branches <CR>', desc = 'Checkout branch', mode = { 'n', 'v' } },
      { '<leader>gc', '<cmd> Telescope git_commits <CR>', desc = 'Checkout commit', mode = { 'n', 'v' } },
      {
        '<leader>gC',
        '<cmd> Telescope git_bcommits <CR>',
        desc = 'Checkout commit(for current file)',
        mode = { 'n', 'v' },
      },
    },
    opts = {
      integrations = {
        telescope = true,
      },
      use_magit_keybindings = false,
    },
    version = '0.0.1',
  },

  -- A plugin to visualise and resolve merge conflicts in neovim
  -- https://github.com/akinsho/git-conflict.nvim
  {
    'akinsho/git-conflict.nvim',
    config = function(_, opts)
      require('git-conflict').setup(opts)

      -- utils.autocmd("User", function()
      --   vim.notify("Conflict detected in " .. vim.fn.expand("<afile>"))
      -- end, {
      --   pattern = "GitConflictDetected",
      -- })
    end,
    keys = {
      '<leader>gQ',
      '<cmd> GitConflictListQf <CR>',
      desc = 'Get all conflict to quickfix',
      mode = { 'n', 'v' },
    },
    opts = {
      default_mappings = {
        both = 'b',
        next = 'n',
        none = '0',
        ours = 'o',
        prev = 'p',
        theirs = 't',
      },
    },
    version = '*',
  },
}
