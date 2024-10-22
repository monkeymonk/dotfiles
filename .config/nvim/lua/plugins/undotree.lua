return {
  -- neovim undotree written in lua
  -- https://github.com/jiaoshijie/undotree
  --[[
  | Mappings | Action                                        |
  |----------|-----------------------------------------------|
  | j        | jump to next undo node                        |
  | gj       | jump to the parent node of the node under the cursor |
  | k        | jump to prev undo node                        |
  | J        | jump to next undo node and undo to this state |
  | K        | jump to prev undo node and undo to this state |
  | q        | quit undotree                                 |
  | p        | jump into the undotree diff window            |
  | Enter    | undo to this state                            |
  ]]
  {
    "jiaoshijie/undotree",
    dependencies = "nvim-lua/plenary.nvim",
    config = true,
    keys = {
      { "<leader>bu", "<cmd>lua require('undotree').toggle()<cr>", desc = "Undotree toggle", mode = "n" },
    },
  },
}
