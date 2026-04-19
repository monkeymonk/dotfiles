return {
	name = "dap",
	src = "https://github.com/mfussenegger/nvim-dap",
	dependencies = {
		"https://github.com/rcarriga/nvim-dap-ui",
		"https://github.com/nvim-neotest/nvim-nio",
		"https://github.com/jay-babu/mason-nvim-dap.nvim",
		"https://github.com/theHamsta/nvim-dap-virtual-text",
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

	setup = function()
		require("util.dap").setup()
	end,

	keys = function(map)
		map.n("<F5>", function()
			require("dap").continue()
		end, "DAP continue")
		map.n("<F10>", function()
			require("dap").step_over()
		end, "DAP step over")
		map.n("<F11>", function()
			require("dap").step_into()
		end, "DAP step into")
		map.n("<S-F11>", function()
			require("dap").step_out()
		end, "DAP step out")

		map.n("<leader>jc", function()
			require("dap").continue()
		end, "DAP continue")
		map.n("<leader>jl", function()
			require("dap").run_last()
		end, "DAP run last")
		map.n("<leader>jb", function()
			require("dap").toggle_breakpoint()
		end, "DAP toggle breakpoint")
		map.n("<leader>jB", function()
			require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
		end, "DAP conditional breakpoint")
		map.n("<leader>jC", function()
			require("dap").clear_breakpoints()
		end, "DAP clear breakpoints")
		map.n("<leader>jo", function()
			require("dap").step_over()
		end, "DAP step over")
		map.n("<leader>ji", function()
			require("dap").step_into()
		end, "DAP step into")
		map.n("<leader>ju", function()
			require("dap").step_out()
		end, "DAP step out")
		map.n("<leader>jt", function()
			require("dap").terminate()
		end, "DAP terminate")
		map.n("<leader>jr", function()
			require("dap").repl.toggle()
		end, "DAP REPL")
		map.n("<leader>jv", function()
			require("dapui").toggle()
		end, "DAP UI")
		map.map({ "n", "v" }, "<leader>je", function()
			require("dapui").eval()
		end, "DAP eval")
		map.n("<leader>jh", function()
			require("util.dap").open_help()
		end, "DAP help")
		map.n("<leader>jP", function()
			require("util.dap").open_project_template()
		end, "DAP project template")
	end,
}
