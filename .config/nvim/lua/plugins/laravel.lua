return {
  {
    "nvim-lua/plenary.nvim",
    lazy = true,
    ft = { "blade" }, -- keep PHP's own gd behavior
    config = function()
      local uv = vim.uv or vim.loop

      local function is_dir(p)
        local st = uv.fs_stat(p)
        return st and st.type == "directory"
      end
      local function file_exists(p)
        local st = uv.fs_stat(p)
        return st and st.type == "file"
      end

      local function find_views_root(start_file)
        local dir = vim.fn.fnamemodify(start_file, ":p:h")
        while dir and dir ~= "/" do
          local candidate = dir .. "/resources/views"
          if is_dir(candidate) then
            return candidate
          end
          dir = vim.fn.fnamemodify(dir, ":h")
        end
        return nil
      end

      local function supports_method(bufnr, method)
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
          if client.supports_method and client:supports_method(method) then
            return true
          end
          local caps = client.server_capabilities or {}
          if method == "textDocument/definition" and (caps.definitionProvider ~= nil) then
            return true
          end
        end
        return false
      end

      -- Find the quoted string under cursor and return (inside, text_before_quote)
      local function string_at_cursor(line, col)
        local i = col + 1
        -- try both quote types
        for _, q in ipairs({ "'", '"' }) do
          -- scan left for q
          local l = nil
          for j = i, 1, -1 do
            local ch = line:sub(j, j)
            if ch == q and line:sub(j - 1, j - 1) ~= "\\" then
              l = j
              break
            end
          end
          -- scan right for q
          if l then
            local r = nil
            for j = i + 1, #line do
              local ch = line:sub(j, j)
              if ch == q and line:sub(j - 1, j - 1) ~= "\\" then
                r = j
                break
              end
            end
            if r and l < i + 1 and r >= i + 1 then
              local before = line:sub(1, l - 1)
              local inside = line:sub(l + 1, r - 1)
              return inside, before
            end
          end
        end
        return nil, nil
      end

      -- Try to get a Blade view/component token at cursor
      local function view_or_component_under_cursor(line, col)
        -- 1) Quoted string after known blade/view calls
        local inside, before = string_at_cursor(line, col)
        if inside and before then
          if
            before:match("@include%w*%s*%($")
            or before:match("@extends%w*%s*%($")
            or before:match("@component%w*%s*%($")
            or before:match("@each%w*%s*%($")
            or before:match("@includeIf%w*%s*%($")
            or before:match("@includeWhen%w*%s*%($")
            or before:match("@includeFirst%w*%s*%($")
            or before:match("view%s*%($")
          then
            return { kind = "view", token = inside }
          end
        end

        -- 2) <x-...> component tag (cursor anywhere in the tag name/attrs)
        local left = line:sub(1, col + 1)
        local start_idx = left:match(".*()<x[%w%-%._:]*")
        if start_idx then
          local after = line:sub(start_idx + 1)
          local name = after:match("^<([xX][%w%-%._:]+)")
          if name then
            return { kind = "component", token = name }
          end
        end

        return nil
      end

      local function normalize_view_token(s)
        -- strip quotes if they leaked in
        s = s:gsub("^['\"]", ""):gsub("['\"]$", "")
        return s
      end

      local function view_exact_path(views_root, token)
        local rel = token:gsub("%.", "/")
        local p1 = ("%s/%s.blade.php"):format(views_root, rel)
        local p2 = ("%s/%s.php"):format(views_root, rel)
        if file_exists(p1) then
          return p1
        end
        if file_exists(p2) then
          return p2
        end
        return nil
      end

      local function first_glob_match(pattern)
        local matches = vim.fn.glob(pattern, false, true)
        if matches and #matches > 0 then
          return matches[1]
        end
        return nil
      end

      local function resolve_view_prefix(views_root, token)
        -- Handle partial names like "sections.he" -> "sections/he*"
        local rel = token:gsub("%.", "/")
        return first_glob_match(("%s/%s*.blade.php"):format(views_root, rel))
          or first_glob_match(("%s/%s*/index.blade.php"):format(views_root, rel))
          or first_glob_match(("%s/%s*.php"):format(views_root, rel))
      end

      local function component_exact_path(views_root, tag)
        -- <x-foo.bar> -> resources/views/components/foo/bar.blade.php
        local name = tag:gsub("^x[-:]", ""):gsub("^x", ""):gsub("::", "/"):gsub("%.", "/")
        local rel = "components/" .. name
        local p1 = ("%s/%s.blade.php"):format(views_root, rel)
        if file_exists(p1) then
          return p1
        end
        return nil
      end

      local function component_prefix_path(views_root, tag)
        local name = tag:gsub("^x[-:]", ""):gsub("^x", ""):gsub("::", "/"):gsub("%.", "/")
        local rel = "components/" .. name
        return first_glob_match(("%s/%s*.blade.php"):format(views_root, rel))
          or first_glob_match(("%s/%s*/index.blade.php"):format(views_root, rel))
      end

      local function jump_to(path)
        vim.cmd("edit " .. vim.fn.fnameescape(path))
      end

      local function blade_gd()
        local bufnr = vim.api.nvim_get_current_buf()

        -- 1) Use LSP if available for this buffer
        if supports_method(bufnr, "textDocument/definition") then
          local params = vim.lsp.util.make_position_params()
          local results = vim.lsp.buf_request_sync(bufnr, "textDocument/definition", params, 150)
          if results then
            for _, res in pairs(results) do
              local def = res.result
              if def then
                vim.lsp.util.jump_to_location(vim.tbl_islist(def) and def[1] or def)
                return
              end
            end
          end
        end

        -- 2) Blade-aware fallback
        local file = vim.api.nvim_buf_get_name(bufnr)
        local views_root = find_views_root(file)
        if not views_root then
          vim.notify("Blade: couldn't locate resources/views", vim.log.levels.WARN)
          return
        end

        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1] or ""
        local info = view_or_component_under_cursor(line, col)

        if not info then
          vim.notify("Blade: no view/component under cursor", vim.log.levels.WARN)
          return
        end

        local token = normalize_view_token(info.token)
        local path = nil

        if info.kind == "view" then
          path = view_exact_path(views_root, token) or resolve_view_prefix(views_root, token)
        else
          path = component_exact_path(views_root, token) or component_prefix_path(views_root, token)
        end

        if path then
          jump_to(path)
        else
          vim.notify(("Blade: view not found for '%s'"):format(token), vim.log.levels.WARN)
        end
      end

      -- Buffer-local mapping for Blade
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "blade" },
        callback = function(args)
          vim.keymap.set("n", "gd", blade_gd, {
            buffer = args.buf,
            silent = true,
            desc = "Go to Definition (Blade-aware)",
          })
        end,
      })
    end,
  },

  -- Vim syntax highlighting for Blade templates.
  -- https://github.com/jwalton512/vim-blade
  {
    "jwalton512/vim-blade",
    ft = { "blade", "php" },
  },

  -- Navigating Blade views within Laravel projects
  -- https://github.com/RicardoRamirezR/blade-nav.nvim
  -- {
  --   "ricardoramirezr/blade-nav.nvim",
  --   dependencies = "hrsh7th/nvim-cmp",
  --   ft = { "blade", "php" },
  --   opts = {
  --     close_tag_on_complete = true, -- default: true
  --   },
  -- },

  -- Best Laravel development experience with Neovim
  -- https://adalessa.github.io/laravel-nvim-docs/
  {
    "adalessa/laravel.nvim",
    cmd = "Laravel",
    config = true,
    dependencies = {
      "tpope/vim-dotenv",
      "nvim-telescope/telescope.nvim",
      "MunifTanjim/nui.nvim",
      "kevinhwang91/promise-async",
    },
    ft = { "blade", "php" },
    keys = {
      { "<leader>ola", ":Laravel artisan<cr>" },
      { "<leader>olr", ":Laravel routes<cr>" },
      { "<leader>olm", ":Laravel related<cr>" },
    },
  },

  -- @NOTE: This messup blade auto-format...
  --[[ {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        blade = { "blade-formatter" },
      },
    },
  }, ]]

  -- tree-sitter grammar for Laravel blade files
  -- https://github.com/EmranMR/tree-sitter-blade
  {
    "EmranMR/tree-sitter-blade",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = function()
      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      parser_config.blade = {
        filetype = "blade",
        install_info = {
          branch = "main",
          files = { "src/parser.c" },
          generate_requires_npm = true,
          requires_generate_from_grammar = true,
          url = "https://github.com/EmranMR/tree-sitter-blade",
        },
      }

      vim.filetype.add({
        pattern = {
          [".*%.blade%.php"] = "blade",
        },
      })
    end,
  },
}
