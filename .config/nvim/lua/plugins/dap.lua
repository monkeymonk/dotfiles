return {
	name = "dap",
	src = "https://github.com/mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio",
		"jay-babu/mason-nvim-dap.nvim",
		"theHamsta/nvim-dap-virtual-text",
	},
	cmd = {
		"DapHelp",
		"DapProjectTemplate",
		"DapContinue",
		"DapToggleBreakpoint",
		"DapClearBreakpoints",
		"DapTerminate",
		"DapToggleRepl",
	},

	install = {
		notes = {
			"Run :DapHelp after install for project-local Docker/Xdebug and Next.js examples.",
			"Adapters are auto-installed via Mason for PHP and Node/Chrome.",
			"Godot uses its built-in DAP server and is configured manually.",
		},
	},

	config = function()
		require("util.dap").setup()
	end,

	keys = {
		{
			"<F5>",
			function()
				require("dap").continue()
			end,
			desc = "DAP continue",
		},
		{
			"<F10>",
			function()
				require("dap").step_over()
			end,
			desc = "DAP step over",
		},
		{
			"<F11>",
			function()
				require("dap").step_into()
			end,
			desc = "DAP step into",
		},
		{
			"<S-F11>",
			function()
				require("dap").step_out()
			end,
			desc = "DAP step out",
		},
		{
			"<leader>jc",
			function()
				require("dap").continue()
			end,
			desc = "DAP continue",
		},
		{
			"<leader>jl",
			function()
				require("dap").run_last()
			end,
			desc = "DAP run last",
		},
		{
			"<leader>jb",
			function()
				require("dap").toggle_breakpoint()
			end,
			desc = "DAP toggle breakpoint",
		},
		{
			"<leader>jB",
			function()
				require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end,
			desc = "DAP conditional breakpoint",
		},
		{
			"<leader>jC",
			function()
				require("dap").clear_breakpoints()
			end,
			desc = "DAP clear breakpoints",
		},
		{
			"<leader>jo",
			function()
				require("dap").step_over()
			end,
			desc = "DAP step over",
		},
		{
			"<leader>ji",
			function()
				require("dap").step_into()
			end,
			desc = "DAP step into",
		},
		{
			"<leader>ju",
			function()
				require("dap").step_out()
			end,
			desc = "DAP step out",
		},
		{
			"<leader>jt",
			function()
				require("dap").terminate()
			end,
			desc = "DAP terminate",
		},
		{
			"<leader>jr",
			function()
				require("dap").repl.toggle()
			end,
			desc = "DAP REPL",
		},
		{
			"<leader>jv",
			function()
				require("dapui").toggle()
			end,
			desc = "DAP UI",
		},
		{
			"<leader>je",
			function()
				require("dapui").eval()
			end,
			desc = "DAP eval",
			mode = { "n", "v" },
		},
		{
			"<leader>jh",
			function()
				require("util.dap").open_help()
			end,
			desc = "DAP help",
		},
		{
			"<leader>jP",
			function()
				require("util.dap").open_project_template()
			end,
			desc = "DAP project template",
		},
	},
}
