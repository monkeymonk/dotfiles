return {
  -- Snippet Engine for Neovim written in Lua.
  -- https://github.com/L3MON4D3/LuaSnip
  {
    "L3MON4D3/LuaSnip",
    init = function()
      -- Simple Snippet Picker
      function pick_snippet()
        local ls = require("luasnip")
        local fzf = require("fzf-lua")

        -- Collect all loaded snippets across all filetypes
        local all_snippets = {}
        for ft, _ in pairs(ls.available() or {}) do
          local snips = ls.get_snippets(ft) or {}
          for _, snip in ipairs(snips) do
            local trigger = snip.trigger or "<no trigger>"
            local name = snip.name or ""
            local doc = (type(snip.get_docstring) == "function") and snip:get_docstring() or {}
            local body = type(doc) == "table" and table.concat(doc, "\n") or tostring(doc or "")
            table.insert(all_snippets, {
              ft = ft,
              trigger = trigger,
              name = name,
              body = body,
              snip = snip,
            })
          end
        end

        if vim.tbl_isempty(all_snippets) then
          vim.notify("No snippets registered.", vim.log.levels.INFO)
          return
        end

        local entries = {}
        local lookup = {}
        for _, s in ipairs(all_snippets) do
          local display = string.format("[%s] %-20s %s", s.ft, s.trigger, s.name)
          table.insert(entries, display)
          lookup[s.ft .. "::" .. s.trigger] = s
        end

        fzf.fzf_exec(entries, {
          prompt = "Snippets> ",
          preview_window = "left:60%",
          preview = function(item)
            -- fzf-lua sometimes passes a table
            if type(item) == "table" then
              item = item[1]
            end
            if type(item) ~= "string" then
              return ""
            end
            local ft, trigger = item:match("%[(.-)%]%s+(%S+)")
            local key = ft and trigger and (ft .. "::" .. trigger) or nil
            if key and lookup[key] then
              return lookup[key].body or ""
            end
            return ""
          end,
          actions = {
            ["default"] = function(selected)
              local item = selected and selected[1]
              if type(item) ~= "string" then
                return
              end
              local ft, trigger = item:match("%[(.-)%]%s+(%S+)")
              local key = ft and trigger and (ft .. "::" .. trigger) or nil
              local s = key and lookup[key] or nil
              if not s then
                vim.notify("Snippet not found for selection", vim.log.levels.WARN)
                return
              end
              -- expand full snippet object (real tabstops work)
              ls.snip_expand(s.snip)
            end,
          },
        })
      end

      vim.keymap.set("n", "<leader>css", pick_snippet, { desc = "Search Snippets (LuaSnip)" })
    end,
  },

  -- Automagical editing and creation of snippets.
  -- https://github.com/chrisgrieser/nvim-scissors
  -- https://code.visualstudio.com/docs/editor/userdefinedsnippets
  -- https://code.visualstudio.com/api/language-extensions/snippet-guide
  -- https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md#vs-code
  {
    "chrisgrieser/nvim-scissors",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      {
        "garymjr/nvim-snippets",
        opts = {
          search_paths = { vim.fn.stdpath("config") .. "/snippets" },
        },
      },
      {
        "neovim/nvim-lspconfig",
        opts = {
          settings = {
            snippet = {
              enable = true,
              source = vim.fn.stdpath("config") .. "/snippets",
            },
          },
        },
      },
    },
    event = "VeryLazy",
    keys = {
      {
        "<leader>cse",
        "<cmd> lua require('scissors').editSnippet() <CR>",
        desc = "Edit snippet",
      },
      {
        "<leader>csa",
        "<cmd> lua require('scissors').addNewSnippet() <CR>",
        desc = "Add snippet",
      },
    },
    opts = {
      jsonFormatter = "jq",
      snippetDir = vim.fn.stdpath("config") .. "/snippets",
    },
  },

  -- Improved Yank and Put functionalities for Neovim
  -- https://github.com/gbprod/yanky.nvim
  {
    "gbprod/yanky.nvim",
    dependencies = "nvim-telescope/telescope.nvim",
    config = function(_, opts)
      require("yanky").setup(opts)
      require("telescope").load_extension("yank_history")
    end,
    keys = {
      {
        "<leader>oh",
        "<cmd> Telescope yank_history <CR>",
        desc = "Yanky history",
      },
      {
        "gp",
        "<Plug>(YankyGPutAfter)",
        desc = "Yanky put after",
      },
      {
        "gP",
        "<Plug>(YankyGPutBefore)",
        desc = "Yanky put before",
      },
      {
        "<C-n>",
        "<Plug>(YankyCycleForward)",
        desc = "Yanky cycle forward",
      },
      {
        "<C-p>",
        "<Plug>(YankyCycleBackward)",
        desc = "Yanky cycle backward",
      },
      {
        "gH",
        "<cmd> lua require('telescope').extensions.yank_history.yank_history() <CR>",
        desc = "Yanky history",
      },
    },
  },
}
