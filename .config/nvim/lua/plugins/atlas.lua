-- Pull requests and issues without leaving the editor. Only the GitHub
-- provider is wired: it authenticates through the `gh` CLI, while Jira,
-- GitLab, and Bitbucket would each need a token in the environment.
--
-- View `search` strings are raw GitHub search queries. Atlas prepends
-- `is:pr` / `is:issue` itself, and for pulls it appends the open/merged/
-- declined state from the dashboard filters (`gpo`/`gpm`/`gpd`) — so pull
-- views must not hardcode a state qualifier. Issue views must.
return {
	name = "atlas",
	src = "https://github.com/emrearmagan/atlas.nvim",
	-- Atlas sets `filetype = markdown` on its description/editor/preview
	-- buffers, so render-markdown attaches through its own `ft` trigger and
	-- is not listed here.
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	cmd = { "Atlas", "AtlasDiff" },

	install = {
		binaries = { "git", "curl", "gh" },
		notes = {
			"GitHub provider needs `gh auth login` with the `repo` and `read:org` scopes.",
			"`:checkhealth atlas` reports provider auth and optional integrations.",
		},
	},

	opts = {
		ui = {
			picker = "snacks",
		},

		pulls = {
			providers = {
				github = {
					views = {
						{ name = "Assigned", key = "1", layout = "plain", search = "assignee:@me archived:false" },
						{ name = "Authored", key = "2", layout = "plain", search = "author:@me archived:false" },
						{
							name = "Reviewing",
							key = "3",
							layout = "compact",
							search = "review-requested:@me archived:false",
						},
						{ name = "Mentions", key = "4", layout = "compact", search = "mentions:@me archived:false" },
					},
					bookmarks = {
						items = {
							["Drafts"] = "is:pr is:draft author:@me",
							["Recently merged"] = "is:pr is:merged author:@me sort:updated-desc",
							["Involves me"] = "is:pr involves:@me sort:updated-desc",
						},
					},
				},
			},
		},

		issues = {
			providers = {
				github = {
					views = {
						{ name = "Assigned", key = "1", layout = "plain", search = "assignee:@me is:open" },
						{ name = "Created", key = "2", layout = "plain", search = "author:@me is:open" },
						{ name = "Mentions", key = "3", layout = "compact", search = "mentions:@me is:open" },
					},
					bookmarks = {
						items = {
							["Bugs"] = "is:issue is:open label:bug",
							["Recently closed"] = "is:issue is:closed author:@me sort:updated-desc",
						},
					},
				},
			},
		},
	},

	keys = {
		{ "<leader>gaa", "<cmd>Atlas<cr>", desc = "Atlas commands" },
		{ "<leader>gap", "<cmd>Atlas pulls github<cr>", desc = "Pull requests" },
		{ "<leader>gai", "<cmd>Atlas issues github<cr>", desc = "Issues" },
		{ "<leader>gar", "<cmd>Atlas review<cr>", desc = "Review pull request" },
		{ "<leader>gac", "<cmd>Atlas create pr<cr>", desc = "Create pull request" },
		{ "<leader>gaI", "<cmd>Atlas create issue<cr>", desc = "Create issue" },
		{ "<leader>gas", "<cmd>Atlas search github<cr>", desc = "Search pulls/issues" },
		{ "<leader>gan", "<cmd>Atlas notes<cr>", desc = "Local review notes" },
		{ "<leader>gal", "<cmd>Atlas logs<cr>", desc = "Toggle Atlas logs" },
	},
}
