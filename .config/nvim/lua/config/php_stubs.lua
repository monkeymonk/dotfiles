local stub_path = vim.fn.expand("~/.local/share/php-stubs")
local vendor_path = stub_path .. "/vendor"
local composer = vim.fn.exepath("composer")

local required_stubs = {
  "php-stubs/wordpress-stubs:^6.0",
  "php-stubs/woocommerce-stubs:^6.0",
  "php-stubs/acf-pro-stubs:^6.0",
}

local function run_cmd(cmd, cwd)
  local Job = require("plenary.job")
  return Job:new({
    command = cmd[1],
    args = vim.list_slice(cmd, 2),
    cwd = cwd or stub_path,
  }):sync()
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
    })
  end

  -- Install other stubs if not yet installed
  for i = 2, #required_stubs do
    local pkg = required_stubs[i]:match("^([^:]+)")
    if vim.fn.isdirectory(vendor_path .. "/" .. pkg) == 0 then
      run_cmd({ composer, "require", "--dev", required_stubs[i] })
    end
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
