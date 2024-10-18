return {

  -- Neo-tree is a Neovim plugin to browse the file system
  -- https://github.com/nvim-neo-tree/neo-tree.nvim
  {
    'nvim-neo-tree/neo-tree.nvim',
    version = '*',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
      'MunifTanjim/nui.nvim',
      {
        's1n7ax/nvim-window-picker',
        config = function()
          require('window-picker').setup {
            filter_rules = {
              autoselect_one = true,
              -- filter using buffer options
              bo = {
                -- if the buffer type is one of following, the window will be ignored
                buftype = { 'terminal', 'quickfix' },
                -- if the file type is one of following, the window will be ignored
                filetype = { 'neo-tree', 'neo-tree-popup', 'notify' },
              },
              include_current_win = false,
            },
          }
        end,
        version = '2.*',
      },
    },
    cmd = 'Neotree',
    keys = {
      { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
    },
    opts = {
      filesystem = {
        window = {
          mappings = {
            ['\\'] = 'close_window',
          },
        },
      },
      window = {
        mappings = {
          ['<CR>'] = 'open_with_window_picker',
          ['w'] = 'open_with_window_picker',
        },
      },
    },
  },
}
