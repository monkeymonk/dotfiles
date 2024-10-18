local M = {}

local function get_tip_file_path(source)
  local file_name
  if string.find(source, "neotip") then
    file_name = "neotips.txt"
  elseif string.find(source, "vtip") then
    file_name = "vtips.txt"
  else
    file_name = "tips.txt"
  end
  return string.format(M.config.save_dir .. "%s", file_name)
end

local function is_result_present(result, source)
  local f = io.open(get_tip_file_path(source), "r")
  if f then
    for line in f:lines() do
      if line == result then
        f:close()
        return true
      end
    end
    f:close()
  end
  return false
end

M.config = {
  save_dir = vim.fn.expand("~/.config/nvim/"),
  tip_files = {
    vim.fn.expand("~/.config/nvim/neotips.txt"),
    vim.fn.expand("~/.config/nvim/vtips.txt"),
    vim.fn.expand("~/.config/nvim/tips.txt"),
  },
  tip_sources = {
    "https://vtip.43z.one",
    -- "https://www.vimiscool.tech/neotip",
  },
}

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  vim.api.nvim_create_user_command("GetTip", function()
    print(M.GetTip())
  end, {})

  vim.api.nvim_create_user_command("FetchTip", function()
    print(M.FetchTip())
  end, {})
end

function M.FetchTip()
  -- Get the last line from a multi-line string
  local function get_last_line(input_string)
    local lines = {}
    for line in input_string:gmatch("[^\r\n]+") do
      table.insert(lines, line)
    end
    return lines[#lines]
  end

  -- Randomly select a tip source
  local tip_source = M.config.tip_sources[math.random(1, #M.config.tip_sources)]

  -- Use 'io.popen' to capture the output of the selected tip source
  local handle = io.popen("curl -s -m 3 " .. tip_source)
  local output = handle:read("*a") -- Read the entire output
  handle:close()

  -- Fallback to local tips if curl command fails or output is empty
  if not output or output == "" then
    return M.GetTip()
  end

  local result = get_last_line(output)

  -- Save the new tip if it's not already present
  if not is_result_present(result, tip_source) then
    local f = io.open(get_tip_file_path(tip_source), "a")
    if f then
      f:write(result .. "\n")
      f:close()
    end
  end

  return result
end

function M.GetTip()
  local total_lines = 0
  local file_lines = {}

  for _, tip_file in ipairs(M.config.tip_files) do
    local f = io.open(tip_file, "r")
    if f then
      for line in f:lines() do
        table.insert(file_lines, line)
        total_lines = total_lines + 1
      end
      f:close()
    end
  end

  if total_lines > 0 then
    local random_line_num = math.random(1, total_lines)
    return file_lines[random_line_num]
  end

  return "No tips found in the specified files."
end

return M
