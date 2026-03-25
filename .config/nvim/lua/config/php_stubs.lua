local stub_path = vim.fn.expand("~/.local/share/php-stubs")
local vendor_path = stub_path .. "/vendor"
local composer = vim.fn.exepath("composer")

local required_stubs = {
  "php-stubs/wordpress-stubs:^6.0",
  "php-stubs/woocommerce-stubs:^6.0",
  "php-stubs/acf-pro-stubs:^6.0",
}

local function run_cmd(cmd, cwd, on_done)
  local Job = require("plenary.job")
  local job = Job:new({
    command = cmd[1],
    args = vim.list_slice(cmd, 2),
    cwd = cwd or stub_path,
    on_exit = function(j, code)
      if code ~= 0 then
        vim.schedule(function()
          vim.notify("php_stubs: command failed: " .. cmd[1], vim.log.levels.WARN)
        end)
      end
      if on_done then
        on_done()
      end
    end,
  })
  job:start()
end

local function install_remaining_stubs(from_index)
  if from_index > #required_stubs then
    return
  end
  local pkg = required_stubs[from_index]:match("^([^:]+)")
  if vim.fn.isdirectory(vendor_path .. "/" .. pkg) == 0 then
    run_cmd({ composer, "require", "--dev", required_stubs[from_index] }, nil, function()
      install_remaining_stubs(from_index + 1)
    end)
  else
    install_remaining_stubs(from_index + 1)
  end
end

local function ensure_php_stubs()
  if composer == "" then
    vim.notify("Composer not found in PATH!", vim.log.levels.ERROR)
    return
  end

  -- Create stub path if not exists
  if vim.fn.isdirectory(stub_path) == 0 then
    vim.fn.mkdir(stub_path, "p")
  end

  -- Initialize composer if needed
  if vim.fn.filereadable(stub_path .. "/composer.json") == 0 then
    run_cmd({
      composer,
      "init",
      "--name=stubs/php",
      "--require-dev=" .. required_stubs[1],
      "-n",
    }, nil, function()
      install_remaining_stubs(2)
    end)
  else
    install_remaining_stubs(2)
  end
end

local function get_installed_stub_paths()
  local paths = {}
  local handle = vim.loop.fs_scandir(stub_path .. "/vendor/php-stubs")
  if handle then
    while true do
      local name, type = vim.loop.fs_scandir_next(handle)
      if not name then
        break
      end
      if type == "directory" then
        table.insert(paths, vendor_path .. "/php-stubs/" .. name)
      end
    end
  end
  return paths
end

return {
  ensure_php_stubs = ensure_php_stubs,
  get_stub_paths = get_installed_stub_paths,
  vendor_path = vendor_path,
}
