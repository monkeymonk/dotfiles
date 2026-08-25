local notify = require("util.notify")

local stub_path = vim.fn.expand("~/.local/share/php-stubs")
local vendor_path = stub_path .. "/vendor"
-- Hand-written stubs Composer does not provide (e.g. the WordPress bootstrap
-- constants defined at runtime by wp-config.php). Kept outside vendor/ so
-- Composer never reclaims it.
local local_path = stub_path .. "/local"
local composer = vim.fn.exepath("composer")

-- Unpinned on purpose: stubs are additive symbol sets, so the newest stable
-- release is always the right one. Pinned majors silently go stale as WordPress
-- moves on (a `^6.0` pin stops matching once WordPress 7 ships).
local required_stubs = {
	"php-stubs/wordpress-stubs:*",
	"php-stubs/woocommerce-stubs:*",
	"php-stubs/acf-pro-stubs:*",
}

local function run_cmd(cmd, on_done)
	vim.system(cmd, { cwd = stub_path }, function(result)
		if result.code ~= 0 then
			vim.schedule(function()
				local message = result.stderr ~= "" and result.stderr or result.stdout
				notify.warn("PHP stubs", "Command failed: " .. cmd[1] .. "\n" .. vim.trim(message))
			end)
		end
		if on_done then
			on_done()
		end
	end)
end

local function install_remaining_stubs(from_index, on_done)
	if from_index > #required_stubs then
		if on_done then
			on_done()
		end
		return
	end
	local pkg = required_stubs[from_index]:match("^([^:]+)")
	if vim.fn.isdirectory(vendor_path .. "/" .. pkg) == 0 then
		run_cmd({ composer, "require", "--dev", required_stubs[from_index] }, function()
			install_remaining_stubs(from_index + 1, on_done)
		end)
	else
		install_remaining_stubs(from_index + 1, on_done)
	end
end

local function get_installed_stub_paths()
	local paths = {}
	local handle = vim.uv.fs_scandir(vendor_path .. "/php-stubs")
	if handle then
		while true do
			local name, type = vim.uv.fs_scandir_next(handle)
			if not name then
				break
			end
			if type == "directory" then
				table.insert(paths, vendor_path .. "/php-stubs/" .. name)
			end
		end
	end
	table.sort(paths)
	if vim.fn.isdirectory(local_path) == 1 then
		table.insert(paths, local_path)
	end
	return paths
end

local function has_installed_stubs()
	return #get_installed_stub_paths() > 0
end

local function refresh_intelephense()
	vim.schedule(function()
		local paths = get_installed_stub_paths()
		if #paths == 0 then
			return
		end
		for _, client in ipairs(vim.lsp.get_clients({ name = "intelephense" })) do
			client.settings = vim.tbl_deep_extend("force", client.settings or {}, {
				intelephense = { environment = { includePaths = paths } },
			})
			client:notify("workspace/didChangeConfiguration", { settings = client.settings })
		end
	end)
end

local function ensure_php_stubs()
	if composer == "" then
		notify.warn("PHP stubs", "Composer is not available")
		return
	end

	if vim.fn.isdirectory(stub_path) == 0 then
		vim.fn.mkdir(stub_path, "p")
	end

	if vim.fn.filereadable(stub_path .. "/composer.json") == 0 then
		run_cmd({
			composer,
			"init",
			"--name=stubs/php",
			"--require-dev=" .. required_stubs[1],
			"-n",
		}, function()
			install_remaining_stubs(2, refresh_intelephense)
		end)
	else
		install_remaining_stubs(1, refresh_intelephense)
	end
end

local function status()
	return {
		composer = composer,
		stub_path = stub_path,
		vendor_path = vendor_path,
		installed = get_installed_stub_paths(),
	}
end

return {
	ensure_php_stubs = ensure_php_stubs,
	get_stub_paths = get_installed_stub_paths,
	has_stubs = has_installed_stubs,
	status = status,
	vendor_path = vendor_path,
}
