-- CodeCompanion chat is driven by CLI agents over ACP (Agent Client Protocol).
-- ACP is only supported by the chat interaction; inline (`:CodeCompanion`) and
-- cmd (`:CodeCompanionCmd`) are HTTP-only upstream, so they are left unmapped
-- here to avoid accidentally hitting API-key adapters.
--
-- The bridge binaries are provisioned by the aic `acp-bridges` package, which
-- pins them and keeps them out of the node-version prefix. Run
-- `~/.claude/bin/acp-doctor.sh` if a chat fails to connect.

local ACP_AGENTS = {
	{ adapter = "claude_code", binary = "claude-agent-acp" },
	{ adapter = "codex", binary = "codex-acp" },
	{ adapter = "opencode", binary = "opencode" },
	{ adapter = "omp", binary = "omp" },
}

local function default_agent()
	for _, agent in ipairs(ACP_AGENTS) do
		if vim.fn.executable(agent.binary) == 1 then
			return agent.adapter
		end
	end
	return ACP_AGENTS[1].adapter
end

return {
	name = "codecompanion",
	src = "https://github.com/olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	cmd = {
		"CodeCompanion",
		"CodeCompanionActions",
		"CodeCompanionChat",
		"CodeCompanionCmd",
		"CodeCompanionCodeReview",
	},

	install = {
		binaries = { "claude-agent-acp", "codex-acp", "opencode", "omp" },
		notes = {
			"Bridges are owned by aic: aic package prepare custom:acp-bridges --run",
			"Diagnose with ~/.claude/bin/acp-doctor.sh (ships to every provider).",
			"Never `npm i -g` a bridge: mise puts npm's prefix inside the node",
			"install, so a node upgrade deletes it silently.",
			"claude-agent-acp: run `claude setup-token`, then export CLAUDE_CODE_OAUTH_TOKEN.",
			"codex-acp: authenticates via OPENAI_API_KEY.",
			"opencode/omp: speak ACP natively, nothing extra to install.",
		},
	},

	config = function()
		require("util.ai_status").setup()

		local extensions = {}
		if pcall(require, "mcphub") then
			extensions.mcphub = {
				callback = "mcphub.extensions.codecompanion",
				opts = {
					-- make_vars = true disabled: mcphub's variables.lua reads
					-- config.interactions.chat.variables, a field the current
					-- codecompanion.nvim no longer defines (removed upstream).
					-- slash_commands/tools still exist and work.
					make_vars = false,
					make_slash_commands = true,
					show_result_in_chat = true,
				},
			}
		end

		require("codecompanion").setup({
			adapters = {
				acp = {
					-- Oh My Pi has no preset adapter; it speaks ACP over stdio.
					omp = function()
						local helpers = require("codecompanion.adapters.acp.helpers")
						return {
							name = "omp",
							formatted_name = "Oh My Pi",
							type = "acp",
							roles = { llm = "assistant", user = "user" },
							commands = { default = { "omp", "acp" } },
							defaults = { mcpServers = {}, timeout = 20000 },
							parameters = {
								protocolVersion = 1,
								clientCapabilities = {
									fs = { readTextFile = true, writeTextFile = true },
								},
								clientInfo = { name = "CodeCompanion.nvim", version = "1.0.0" },
							},
							handlers = {
								setup = function()
									return true
								end,
								auth = function()
									return true
								end,
								form_messages = function(self, messages, capabilities)
									return helpers.form_messages(self, messages, capabilities)
								end,
								on_exit = function() end,
							},
						}
					end,
				},
			},
			display = {
				chat = {
					window = {
						-- The chat buffer inherits number/signcolumn/cursorline
						-- from lua/config/options.lua otherwise; upstream only
						-- sets the wrap-related options here, and user config is
						-- deep-extended onto them.
						opts = {
							number = false,
							relativenumber = false,
							signcolumn = "no",
							cursorline = false,
							list = false,
						},
					},
					-- Streamed reasoning arriving inside a closed fold is one of
					-- the "nothing is happening" cases.
					fold_reasoning = false,
					intro_message = "CodeCompanion ✨ ? options · q stop request · gm send follow-up while streaming · ga change adapter",
				},
			},
			interactions = {
				chat = { adapter = default_agent() },
			},
			extensions = extensions,
		})
	end,

	keys = {
		{ "<leader>aa", "<cmd>CodeCompanionActions<cr>", desc = "CodeCompanion actions" },
		{ "<leader>aa", "<cmd>CodeCompanionActions<cr>", desc = "CodeCompanion actions", mode = "x" },
		{ "<leader>at", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle CodeCompanion chat" },
		{ "<leader>ae", "<cmd>CodeCompanionChat Add<cr>", desc = "Add selection to CodeCompanion", mode = "x" },
		{
			"<leader>ac",
			function()
				require("util.ai_status").focus()
			end,
			desc = "Focus in-flight CodeCompanion chat",
		},
	},
}
