local M = {}

local notify = require("util.notify")
local scratch = require("util.scratch")

local state = {
	extensions = {},
	configured = false,
}

local js_filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" }

local function add_configurations(filetypes, configs)
	local dap = require("dap")
	for _, ft in ipairs(filetypes) do
		dap.configurations[ft] = dap.configurations[ft] or {}
		vim.list_extend(dap.configurations[ft], vim.deepcopy(configs))
	end
end

local function add_single_configuration(filetype, config)
	add_configurations({ filetype }, { config })
end

local function apply_extension(ext)
	local dap = require("dap")

	if ext.adapters then
		for name, adapter in pairs(ext.adapters) do
			dap.adapters[name] = adapter
		end
	end

	if ext.configurations then
		for filetype, configs in pairs(ext.configurations) do
			add_configurations({ filetype }, configs)
		end
	end
end

local function cwd_has(path)
	return vim.uv.fs_stat(vim.fs.joinpath(vim.fn.getcwd(), path)) ~= nil
end

local function package_json_contains(pattern)
	local path = vim.fs.joinpath(vim.fn.getcwd(), "package.json")
	if vim.uv.fs_stat(path) == nil then
		return false
	end
	local lines = vim.fn.readfile(path)
	local text = table.concat(lines, "\n")
	return text:find(pattern, 1, true) ~= nil
end

local function project_kind()
	if cwd_has("artisan") then
		return "laravel"
	end
	if cwd_has("wp-config.php") or cwd_has("wp-content") then
		return "wordpress"
	end
	if cwd_has("project.godot") then
		return "godot"
	end
	if cwd_has("package.json") and (package_json_contains('"next"') or package_json_contains('"nextjs"')) then
		return "nextjs"
	end
	return "generic"
end

local function project_template(kind)
	if kind == "laravel" then
		return {
			"-- .nvim.lua",
			'-- Laravel / Docker / Xdebug example',
			'require("util.dap").extend({',
			"  configurations = {",
			"    php = {",
			"      {",
			'        name = "PHP: Laravel Docker Xdebug",',
			'        type = "php",',
			'        request = "launch",',
			"        port = 9003,",
			"        pathMappings = {",
			'          ["/var/www/html"] = "${workspaceFolder}",',
			'          ["/app"] = "${workspaceFolder}",',
			"        },",
			"      },",
			"    },",
			"  },",
			"})",
			"",
			"-- Notes:",
			"-- 1. Publish/expose port 9003 from the PHP container.",
			"-- 2. Make Xdebug connect back to your Neovim host.",
			"-- 3. Adjust pathMappings to the real container path.",
		}
	end

	if kind == "wordpress" then
		return {
			"-- .nvim.lua",
			'-- WordPress / Docker / Xdebug example',
			'require("util.dap").extend({',
			"  configurations = {",
			"    php = {",
			"      {",
			'        name = "PHP: WordPress Docker Xdebug",',
			'        type = "php",',
			'        request = "launch",',
			"        port = 9003,",
			"        pathMappings = {",
			'          ["/var/www/html"] = "${workspaceFolder}",',
			'          ["/usr/src/wordpress"] = "${workspaceFolder}",',
			"        },",
			"      },",
			"    },",
			"  },",
			"})",
			"",
			"-- Notes:",
			"-- 1. Pick the container path your image actually uses.",
			"-- 2. Keep port 9003 reachable from PHP to the host.",
		}
	end

	if kind == "nextjs" then
		return {
			"-- .nvim.lua",
			'-- Next.js server + browser debugging example',
			'require("util.dap").extend({',
			"  configurations = {",
			"    typescript = {",
			"      {",
			'        name = "Next.js: Node attach",',
			'        type = "node2",',
			'        request = "attach",',
			'        cwd = "${workspaceFolder}",',
			'        processId = require("dap.utils").pick_process,',
			"      },",
			"      {",
			'        name = "Next.js: Chrome attach",',
			'        type = "chrome",',
			'        request = "attach",',
			"        port = 9222,",
			'        url = "http://localhost:3000",',
			'        webRoot = "${workspaceFolder}",',
			"      },",
			"    },",
			"    typescriptreact = {},",
			"  },",
			"})",
			"",
			"-- Notes:",
			"-- 1. Start Next.js with inspect enabled for server-side debugging.",
			"--    Example: NODE_OPTIONS=--inspect npm run dev",
			"-- 2. Start Chrome with --remote-debugging-port=9222 for browser attach.",
		}
	end

	if kind == "godot" then
		return {
			"-- .nvim.lua",
			'-- Godot DAP example',
			'require("util.dap").extend({',
			"  adapters = {",
			"    godot = {",
			'      type = "server",',
			'      host = "127.0.0.1",',
			"      port = 6006,",
			"    },",
			"  },",
			"  configurations = {",
			"    gdscript = {",
			"      {",
			'        name = "Godot: Attach",',
			'        type = "godot",',
			'        request = "launch",',
			'        project = "${workspaceFolder}",',
			"        port = 6007,",
			"      },",
			"    },",
			"  },",
			"})",
			"",
			"-- Notes:",
			"-- 1. Enable external editor debugging in Godot.",
			"-- 2. Keep the editor/project running before attaching.",
			"-- 3. Adjust ports if you changed them in Godot.",
		}
	end

	return {
		"-- .nvim.lua",
		"-- Generic project-local DAP extension example",
		'require("util.dap").extend({',
		"  adapters = {",
		"    -- custom_adapter = { type = 'server' | 'executable', ... },",
		"  },",
		"  configurations = {",
		"    -- php = { ... },",
		"    -- typescript = { ... },",
		"    -- gdscript = { ... },",
		"  },",
		"})",
	}
end

function M.open_help()
	local lines = {
		"# DAP Help",
		"",
		"Keys",
		"- `<F5>` / `<leader>jc`: continue or start selected config",
		"- `<F10>` / `<leader>jo`: step over",
		"- `<F11>` / `<leader>ji`: step into",
		"- `<S-F11>` / `<leader>ju`: step out",
		"- `<leader>jb`: toggle breakpoint",
		"- `<leader>jB`: conditional breakpoint",
		"- `<leader>jC`: clear breakpoints",
		"- `<leader>jl`: run last",
		"- `<leader>jt`: terminate",
		"- `<leader>jr`: toggle REPL",
		"- `<leader>jv`: toggle DAP UI",
		"- `<leader>je`: eval under cursor/selection",
		"- `<leader>jP`: open a project-local `.nvim.lua` template",
		"",
		"Installed adapters",
		"- PHP: `php-debug-adapter` via Mason",
		"- Node/browser: `node-debug2-adapter` and `chrome-debug-adapter` via Mason",
		"- Godot: manual server adapter, default DAP port `6006`",
		"",
		"Project-local setup",
		"- This config already enables `:h exrc`, so put project DAP overrides in `.nvim.lua` at repo root.",
		"- Use `require(\"util.dap\").extend({...})` there.",
		"",
		"PHP / Docker / Xdebug",
		"- Base config listens on Xdebug port `9003`.",
		"- Expose port `9003` from the container and set Xdebug to connect back to your host.",
		"- For Docker path mapping, add a project-local config like:",
		"",
		"```lua",
		"require(\"util.dap\").extend({",
		"  configurations = {",
		"    php = {",
		"      {",
		"        name = \"PHP: Docker Xdebug\",",
		"        type = \"php\",",
		"        request = \"launch\",",
		"        port = 9003,",
		"        pathMappings = {",
		"          [\"/var/www/html\"] = \"${workspaceFolder}\",",
		"          [\"/app\"] = \"${workspaceFolder}\",",
		"        },",
		"      },",
		"    },",
		"  },",
		"})",
		"```",
		"",
		"Next.js / TypeScript",
		"- `Node: Attach to process` works when the server is started with `--inspect` / `NODE_OPTIONS=--inspect`.",
		"- `Chrome: Attach localhost:9222` works when Chrome is started with `--remote-debugging-port=9222`.",
		"- For browser source maps or custom URLs/webRoot, add a project-local override:",
		"",
		"```lua",
		"require(\"util.dap\").extend({",
		"  configurations = {",
		"    typescript = {",
		"      {",
		"        name = \"Next.js: Chrome attach\",",
		"        type = \"chrome\",",
		"        request = \"attach\",",
		"        port = 9222,",
		"        webRoot = \"${workspaceFolder}\",",
		"        url = \"http://localhost:3000\",",
		"      },",
		"    },",
		"  },",
		"})",
		"```",
		"",
		"Godot / GDScript",
		"- In Godot, enable external editor debugging and keep the project open in the editor.",
		"- Godot's docs say the default DAP ports are `6006` for the adapter and `6007` for the launch config.",
		"- Base config uses those defaults; if you changed them in Godot, override them in `.nvim.lua`.",
		"",
		"```lua",
		"require(\"util.dap\").extend({",
		"  adapters = {",
		"    godot = { type = \"server\", host = \"127.0.0.1\", port = 6006 },",
		"  },",
		"  configurations = {",
		"    gdscript = {",
		"      { name = \"Godot: Attach\", type = \"godot\", request = \"launch\", project = \"${workspaceFolder}\", port = 6007 },",
		"    },",
		"  },",
		"})",
		"```",
	}

	scratch.open({
		title = "DAP Help",
		lines = lines,
		filetype = "markdown",
		reuse = true,
		wrap = true,
		linebreak = true,
	})
end

function M.open_project_template()
	local kind = project_kind()
	scratch.open({
		title = "DAP Project Template",
		lines = project_template(kind),
		filetype = "lua",
		reuse = true,
	})
	notify.info("DAP", "Opened " .. kind .. " project template")
end

function M.extend(ext)
	state.extensions[#state.extensions + 1] = ext
	if state.configured then
		apply_extension(ext)
	end
end

function M.setup()
	if state.configured then
		return
	end
	state.configured = true

	local dap = require("dap")
	local dapui = require("dapui")
	local mason_dap = require("mason-nvim-dap")

	for _, sign in ipairs({
		{ name = "DapBreakpoint", text = "B", texthl = "DiagnosticError" },
		{ name = "DapBreakpointCondition", text = "C", texthl = "DiagnosticWarn" },
		{ name = "DapBreakpointRejected", text = "R", texthl = "DiagnosticWarn" },
		{ name = "DapLogPoint", text = "L", texthl = "DiagnosticInfo" },
		{ name = "DapStopped", text = ">", texthl = "DiagnosticOk", linehl = "Visual" },
	}) do
		vim.fn.sign_define(sign.name, sign)
	end

	dapui.setup({
		layouts = {
			{
				elements = { { id = "scopes", size = 0.55 }, { id = "breakpoints", size = 0.15 }, { id = "stacks", size = 0.15 }, { id = "watches", size = 0.15 } },
				position = "right",
				size = 48,
			},
			{
				elements = { { id = "repl", size = 0.5 }, { id = "console", size = 0.5 } },
				position = "bottom",
				size = 12,
			},
		},
	})

	require("nvim-dap-virtual-text").setup({
		commented = true,
	})

	dap.listeners.after.event_initialized["dapui_config"] = function()
		dapui.open()
	end
	dap.listeners.before.event_terminated["dapui_config"] = function()
		dapui.close()
	end
	dap.listeners.before.event_exited["dapui_config"] = function()
		dapui.close()
	end

	mason_dap.setup({
		ensure_installed = { "php", "node2", "chrome" },
		handlers = {
			function(config)
				require("mason-nvim-dap").default_setup(config)
			end,
		},
	})

	add_single_configuration("php", {
		name = "PHP: Listen for Xdebug",
		type = "php",
		request = "launch",
		port = 9003,
	})

	add_configurations(js_filetypes, {
		{
			name = "Node: Launch current file",
			type = "node2",
			request = "launch",
			program = "${file}",
			cwd = "${workspaceFolder}",
			sourceMaps = true,
			protocol = "inspector",
			console = "integratedTerminal",
		},
		{
			name = "Node: Attach to process",
			type = "node2",
			request = "attach",
			processId = require("dap.utils").pick_process,
			cwd = "${workspaceFolder}",
		},
		{
			name = "Chrome: Attach localhost:9222",
			type = "chrome",
			request = "attach",
			port = 9222,
			webRoot = "${workspaceFolder}",
			url = function()
				return vim.fn.input("App URL: ", "http://localhost:3000")
			end,
		},
	})

	dap.adapters.godot = {
		type = "server",
		host = "127.0.0.1",
		port = 6006,
	}

	add_single_configuration("gdscript", {
		name = "Godot: Attach to running editor",
		type = "godot",
		request = "launch",
		project = "${workspaceFolder}",
		port = 6007,
	})

	for _, ext in ipairs(state.extensions) do
		apply_extension(ext)
	end

	vim.api.nvim_create_user_command("DapHelp", M.open_help, { desc = "Open DAP help" })
	vim.api.nvim_create_user_command("DapProjectTemplate", M.open_project_template, { desc = "Open DAP project template" })
end

return M
