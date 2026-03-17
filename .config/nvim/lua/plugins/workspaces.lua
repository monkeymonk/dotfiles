return {
  {
    "akinsho/bufferline.nvim",
    enabled = false,
  },

  {
    "LazyVim/LazyVim",
    init = function()
      vim.opt.showtabline = 1

      local state = {}

      local function tab_key(tab)
        tab = tab or vim.api.nvim_get_current_tabpage()
        return tostring(tab)
      end

      local function ensure_tab(tab)
        local key = tab_key(tab)
        if not state[key] then
          state[key] = { buffers = {} }
        end
        return state[key]
      end

      local function valid_buffer(buf)
        if not buf or not vim.api.nvim_buf_is_valid(buf) then
          return false
        end
        if not vim.bo[buf].buflisted then
          return false
        end
        local bt = vim.bo[buf].buftype
        if bt == "nofile" or bt == "prompt" or bt == "quickfix" then
          return false
        end
        return true
      end

      local function list_index(list, value)
        for i, v in ipairs(list) do
          if v == value then
            return i
          end
        end
        return nil
      end

      local function prune_workspace(tab)
        local ws = ensure_tab(tab)
        local new = {}
        for _, buf in ipairs(ws.buffers) do
          if valid_buffer(buf) then
            table.insert(new, buf)
          end
        end
        ws.buffers = new
        return ws.buffers
      end

      local function track_buffer(buf, tab)
        buf = buf or vim.api.nvim_get_current_buf()
        tab = tab or vim.api.nvim_get_current_tabpage()

        if not valid_buffer(buf) then
          return
        end

        local ws = ensure_tab(tab)
        if not list_index(ws.buffers, buf) then
          table.insert(ws.buffers, buf)
        end
      end

      local function remove_buffer_everywhere(buf)
        for _, ws in pairs(state) do
          local new = {}
          for _, b in ipairs(ws.buffers) do
            if b ~= buf and valid_buffer(b) then
              table.insert(new, b)
            end
          end
          ws.buffers = new
        end
      end

      local function workspace_buffers()
        track_buffer()
        return prune_workspace()
      end

      local function cycle_workspace_buffer(dir)
        local bufs = workspace_buffers()
        if #bufs == 0 then
          return
        end

        local current = vim.api.nvim_get_current_buf()
        local idx = list_index(bufs, current) or 1

        local target
        if dir > 0 then
          target = bufs[(idx % #bufs) + 1]
        else
          target = bufs[((idx - 2 + #bufs) % #bufs) + 1]
        end

        if target and vim.api.nvim_buf_is_valid(target) then
          vim.cmd("buffer " .. target)
        end
      end

      local function workspace_buffer_picker()
        local bufs = workspace_buffers()
        if #bufs == 0 then
          vim.notify("No buffers in current workspace", vim.log.levels.INFO)
          return
        end

        local items = {}
        local current = vim.api.nvim_get_current_buf()

        for _, buf in ipairs(bufs) do
          local name = vim.api.nvim_buf_get_name(buf)
          if name == "" then
            name = "[No Name]"
          else
            name = vim.fn.fnamemodify(name, ":~:.")
          end

          local flags = {}
          if buf == current then
            table.insert(flags, "%")
          end
          if vim.bo[buf].modified then
            table.insert(flags, "+")
          end

          local label = name
          if #flags > 0 then
            label = label .. " [" .. table.concat(flags, "") .. "]"
          end

          table.insert(items, {
            buf = buf,
            label = label,
          })
        end

        vim.ui.select(items, {
          prompt = "Workspace buffers",
          format_item = function(item)
            return item.label
          end,
        }, function(choice)
          if choice and choice.buf and vim.api.nvim_buf_is_valid(choice.buf) then
            vim.cmd("buffer " .. choice.buf)
          end
        end)
      end

      local function global_buffer_picker()
        local ok, snacks = pcall(require, "snacks")
        if ok and snacks and snacks.picker then
          snacks.picker.buffers()
        else
          vim.notify("Snacks picker is not available", vim.log.levels.WARN)
        end
      end

      local group = vim.api.nvim_create_augroup("WorkspaceTabs", { clear = true })

      vim.api.nvim_create_autocmd({ "BufEnter", "TabEnter" }, {
        group = group,
        callback = function(args)
          track_buffer(args.buf)
        end,
      })

      vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
        group = group,
        callback = function(args)
          remove_buffer_everywhere(args.buf)
        end,
      })

      vim.api.nvim_create_autocmd("TabClosed", {
        group = group,
        callback = function()
          local alive = {}
          for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
            local key = tostring(tab)
            if state[key] then
              alive[key] = state[key]
            end
          end
          state = alive
        end,
      })

      local map = function(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { silent = true, desc = desc })
      end

      map("<Tab>", function()
        cycle_workspace_buffer(1)
      end, "Next workspace buffer")

      map("<S-Tab>", function()
        cycle_workspace_buffer(-1)
      end, "Previous workspace buffer")

      map("<leader>bb", workspace_buffer_picker, "Workspace buffers")
      map("<leader>bB", global_buffer_picker, "All buffers")

      map("]t", "<cmd>tabnext<cr>", "Next tab")
      map("[t", "<cmd>tabprevious<cr>", "Previous tab")
      map("<leader>tn", "<cmd>tabnew<cr>", "New tab")
      map("<leader>tc", "<cmd>tabclose<cr>", "Close tab")
    end,
  },
}
