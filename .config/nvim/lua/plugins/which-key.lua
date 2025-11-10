local function get_project_root()
  -- Find the nearest .git directory or return the current working directory
  local root = vim.fn.finddir(".git", ";")
  if root == "" then
    return vim.fn.getcwd() -- Fallback to current working directory if not found
  end
  return vim.fn.fnamemodify(root, ":h") -- Get the directory of the .git folder
end

local function is_laravel_project()
  local root = get_project_root()
  local artisan_path = root .. "/artisan"
  local exists = vim.fn.filereadable(artisan_path) == 1
  -- vim.notify(
  --   "Laravel project check: " .. artisan_path .. " - " .. (exists and "Found artisan" or "artisan not found"),
  --   vim.log.levels.INFO
  -- )
  return exists
end

local function is_godot_project()
  local root = get_project_root()
  local godot_file = root .. "/*.godot"
  local exists = vim.fn.glob(godot_file) ~= "" or vim.fn.isdirectory(root .. "/Godot")
  -- vim.notify(
  --   "Godot project check: " .. godot_file .. " - " .. (exists and "Found Godot project" or "No Godot project found"),
  --   vim.log.levels.INFO
  -- )
  return exists
end

return {
  -- Create key bindings that stick. WhichKey is a lua plugin for Neovim 0.5 that displays a popup with possible keybindings of the command you started typing.
  -- https://github.com/folke/which-key.nvim
  -- https://www.nerdfonts.com/cheat-sheet
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      spec = {
        -- hidden
        { "<leader>-", hidden = true },
        { "<leader>D", hidden = true },
        { "<leader>|", hidden = true },
        { "<leader>l", hidden = true },
        { "<leader>L", hidden = true },
        -- groups
        {
          "<leader>G",
          group = "Godot",
          hidden = not is_godot_project(),
        },
        { "<leader>a", group = "ai" },
        {
          "<leader>aN",
          group = "NeoAI",
          desc = "NeoAI commands",
        },
        { "<leader>m", group = "markers" },
        { "<leader>n", group = "notes" },
        { "<leader>od", group = "database" },
        {
          "<leader>ol",
          group = "Laravel",
          hidden = not is_laravel_project(),
        },
        { "<leader>os", group = "snippets" },
        {
          "<leader>qL",
          "<cmd> Lazy <CR>",
          desc = "Lazy",
        },
        {
          "<leader>qV",
          function()
            LazyVim.news.changelog()
          end,
          desc = "LazyVim Changelog",
        },
      },
    },
  },

  -- Screencast your keys in Neovim
  -- https://github.com/NStefan002/screenkey.nvim
  {
    "NStefan002/screenkey.nvim",
    lazy = false,
    version = "*", -- or branch = "main", to use the latest commit
  },
}
