# Neovim config

Personal Neovim 0.12+ config. [zpack.nvim](https://github.com/zuqini/zpack.nvim)
(thin layer over native `vim.pack`) for plugins, snacks for the fuzzy stack,
lspsaga for LSP UI, blink.cmp for completion, conform/nvim-lint for
formatting/linting, neogit + gitsigns for git, atlas for GitHub PRs/issues,
code-review for local pre-push review, triforce for coding stats,
persistence for sessions. track-action.nvim is installed but gated behind
`nvim-0.13`: it stays dormant on 0.12; on 0.13 it registers `<leader>ta` and
the conditional which-key `tracking` group.

```
init.lua                       Entry point. Bootstraps in fixed order.
lua/config/                    User-level configuration.
  options.lua                  vim.opt, filetypes, neovide.
  autocmds.lua                 Cursor restore, trailing whitespace strip, etc.
  diagnostics.lua              vim.diagnostic.config.
  lsp.lua                      Loads servers, applies blink capabilities,
                               enables them via vim.lsp.enable().
  lsp/servers.lua              Per-server tables: cmd, filetypes, root_markers.
  lsp/commands.lua             :LspInstall, :PhpStubsInstall, :PhpStubsStatus.
  keymaps/                     Leader-prefix keymap groups.
    core.lua, buffers.lua, windows.lua, navigation.lua, ui.lua
  actions/                     Small action modules used by keymaps.
  php_stubs.lua                Composer-managed PHP stubs for intelephense.
lua/plugins/                   One file per plugin spec. Auto-discovered.
lua/util/                      Self-contained helpers (no plugin deps).
  plugin_specs.lua              Reads name/install metadata from lua/plugins/*.lua.
  mason_ensure.lua             :MasonEnsure auto-installer.
  pickers.lua                  Snacks picker shortcuts.
  quicklist.lua                Quickfix/loclist helpers.
  sessions.lua                 Named sessions per cwd.
  markers.lua                  Cursor-position markers.
  native_tools.lua             :Undotree, :DiffTool wrapping nvim.difftool.
  snippets.lua                 LuaSnip loaders for ./.luasnippets, etc.
  blade_nav.lua                Blade view/component navigation under cursor.
  dap.lua                      DAP adapter glue (PHP/Xdebug, JS, Godot).
  scratch.lua                  Scratch buffer helper.
  memory_sheet.lua             Generated :MemorySheet quick-reference popup.
  dashboard/                   ASCII art + tips for the Snacks dashboard.
luasnippets/                   User Lua snippets (filetype-named files).
snippets/                      User VS Code-style JSON snippets (Scissors).
```

## First run

```sh
nvim
```

`vim.pack.add` clones zpack.nvim itself on first run, then `require("zpack").setup()`
clones any missing plugins declared in `lua/plugins/`, loads eager ones
immediately, and registers lazy triggers for the rest. Subsequent launches are fast.

Then install the LSP/tooling binaries:

```vim
:MasonEnsure        " installs everything declared by your specs
:MasonEnsureList    " preview only — no installs
```

External tools that **don't** come from Mason:

| Tool | Install |
|---|---|
| `pint` (Laravel formatter) | `composer global require laravel/pint` |
| `rustfmt` | `rustup component add rustfmt` |
| `mcp-hub` | `npm i -g mcp-hub@latest` |

## Plugin management

```vim
:Pack update        " update all plugins (skip confirm: :Pack! update)
:Pack restore       " restore to lockfile state
:Pack clean         " remove plugins no longer in lua/plugins/
:Pack build [name]  " rerun a plugin's build hook
```

`<leader>up` lists loaded vs lazy plugins; `<leader>uP` runs `:Pack update`.

Plugins live under `~/.local/share/nvim/site/pack/core/opt/`. The lockfile is
`nvim-pack-lock.json` in this directory.

### Adding a plugin

Drop a new file in `lua/plugins/`. The spec format is:

```lua
return {
  src = "https://github.com/owner/repo",      -- required
  name = "repo",                              -- inferred from src tail
  dependencies = { "https://github.com/..." },

  -- One of these triggers makes the plugin lazy:
  event = "BufReadPost",                      -- string or list
  ft = { "lua", "tsx" },
  cmd = { "Foo", "Bar" },
  keys = { { "<leader>x", "<cmd>Foo<cr>", desc = "Foo" } }, -- also a trigger
  lazy = true,                                -- force lazy with no trigger

  -- One of these initializes the plugin:
  opts = { ... },                             -- passed to require(main).setup
  config = function(plugin, opts) ... end,    -- full custom init

  -- Optional:
  main = "module.name",                       -- override module-name inference
  priority = 100,                             -- higher → earlier eager load
  build = "<cmd>" or function(plugin) end,    -- runs on PackChanged
  init = function(plugin) end,                -- runs at startup, even if lazy
  cond = function() return ... end,           -- installs but skips load if false
  enabled = false,                            -- skip install entirely
  install = {                                 -- consumed by :checkhealth pack
    binaries = { "..." },
    packages = { npm = {...}, composer = {...} },
    notes = { "..." },
  },
}
```

`keys` counts as a lazy trigger and auto-sets `lazy = true` unless overridden
— set `lazy = false` explicitly on a plugin that declares `keys` but must
still load eagerly (see `snacks.lua`, `persistence.lua`, `noice.lua`,
`yanky.lua`).

After saving, restart Neovim — the new plugin will be cloned by `vim.pack.add`
on next startup.

### Removing a plugin

Delete `lua/plugins/<name>.lua`, restart, then `:Pack clean` to prune the
clone from disk (or `rm -rf ~/.local/share/nvim/site/pack/core/opt/<dir>`).

## Keymaps

Leader is `<Space>`, local-leader is `,`. All groups are described in
`lua/plugins/which-key.lua` and shown by which-key on `<Space>`.

### Search (`<leader>s`)

| Key | Action |
|---|---|
| `<leader>sf` | Find files |
| `<leader>sg` | Live grep |
| `<leader>sG` | Grep in current file's directory |
| `<leader>sw` | Grep word under cursor |
| `<leader>sb` | Buffers |
| `<leader>sh` | Help tags |
| `<leader>so` | Recent files |
| `<leader>ss` | Document symbols |

Two search shortcuts and the explorer sit at the top level rather than inside
a group:

| Key | Action |
|---|---|
| `<leader><space>` | Find files |
| `<leader>/` | Live grep |
| `<leader>e` | Snacks file explorer |

`<leader><space>` and `<leader>/` are deliberate top-level shortcuts for keys
that also live in their canonical search group (`<leader>sf`, `<leader>sg`).
`<leader>bb` is likewise a deliberate shortcut for `<leader>sb`, but remains
inside the buffer group. Together, these are the only sanctioned duplicate
bindings. They replace the old `ff`/`sf`, `fb`/`sb` and `fo`/`so` alias pairs,
which are gone along with the whole `<leader>f` root.

In the grep picker, type `<query> -- <glob> !<exclude>` to filter, e.g.
`TODO -- *.lua !test/*`. `<C-q>` sends results to the quickfix list.

### Editing

| Key | Action |
|---|---|
| `x{motion}` (n) | Delete by motion without yanking (`"_d`), e.g. `xiw` deletes the inner word |
| `xx` (n) | Delete the current line without yanking (`"_dd`) |
| `x` (x) | Delete the visual selection without yanking (`"_d`) |
| `<Esc>` (n) | Clear search highlighting and native multicursors |
| `<leader>y` | Yank history (yanky) |

Normal `x` is a black-hole delete operator: `xiw` deletes the inner word, `xx`
deletes the current line, and `xl` deletes one character. Visual `x` deletes
the selection without yanking. Native `D` (delete to end of line) and `X`
(delete the previous character) are intentionally untouched; `<leader>D` is
removed.

On Neovim 0.13, native `Q` is no longer shadowed and creates multicursors.
`<C-l>` remains tmux NavigateRight, so normal `<Esc>` is the alternate clear
action: it clears multicursors while retaining its existing search-highlight
clearing behavior. In insert or visual mode, the first Escape only exits that
mode; a subsequent normal Escape clears the multicursors.

### Buffers (`<leader>b`)

| Key | Action |
|---|---|
| `<S-h>` / `<S-l>` | Previous / next buffer |
| `<leader>bb` | Buffer picker |
| `<leader>bd` | Delete buffer (preserves window layout) |
| `<leader>bD` | Delete other buffers |
| `<leader>be` | New empty buffer |

### Windows (`<leader>w`)

| Key | Action |
|---|---|
| `<C-h/j/k/l>` | Navigate splits (also tmux-aware) |
| `<C-Up/Down/Left/Right>` | Resize split |
| `<leader>ws` / `<leader>wv` | Horizontal / vertical split |
| `<leader>wd` / `<leader>ww` | Close / cycle window |
| `<leader>wp` | Window picker |

### Navigation lists (`<leader>x`)

`<leader>x` is the nav/list root. Lowercase is the native list, uppercase is
the Trouble view — that pattern is now consistent across both pairs.

| Key | Action |
|---|---|
| `<leader>xq` / `<leader>xQ` | Toggle quickfix / Trouble quickfix |
| `<leader>xl` / `<leader>xL` | Toggle location list / Trouble loclist |
| `]q` / `[q` | Next/prev quickfix item |
| `]l` / `[l` | Next/prev loclist item |
| `<leader>xr` | Replace-in-files for quickfix entries (interactive) |

#### Arglist (`<leader>xa`)

| Key | Action |
|---|---|
| `<leader>xaa` | Set arglist to current file only |
| `<leader>xas` | Show arglist (picker) |
| `<leader>xan` / `<leader>xap` | Next / previous arg |
| `<leader>xaf` / `<leader>xal` | First / last arg |
| `<leader>xae` | Add current file to arglist |
| `<leader>xad` | Remove file from arglist |

#### Markers (`<leader>xm`)

Lightweight in-session bookmarks (separate from native `m{a-z}` marks).

| Key | Action |
|---|---|
| `<leader>xma` | Add marker at cursor |
| `<leader>xml` | Pick from markers |
| `<leader>xmd` | Delete a marker |
| `<leader>xmn` / `<leader>xmp` | Next / previous marker |

In the quickfix window, `dd` or `x` removes an item; `>` / `<` expand /
collapse context (quicker.nvim).

### LSP & code (`<leader>c` and `g`)

LSP UI provided by **lspsaga**.

| Key | Action |
|---|---|
| `gd` | Goto definition (lspsaga) |
| `gD` | Peek definition |
| `gr` | References |
| `gi` | Goto implementation |
| `gy` / `gY` | Goto / peek type definition |
| `K` | Hover |
| `gK` / `<C-k>` (insert) | Signature help |
| `<leader>ca` | Code action |
| `<leader>cr` | Rename |
| `<leader>cf` (n, x) | Format buffer or visual range (conform, LSP fallback) |
| `<leader>co` | Outline |
| `<leader>ci` / `<leader>cO` | Incoming / outgoing calls |
| `<leader>ch` | Toggle inlay hints |
| `<leader>cl` | LSP info |
| `<leader>cR` | Restart LSP |
| `<leader>cL` | LSP log |
| `<leader>cn` | Generate annotation (neogen) |
| `<leader>cT` | Trouble LSP view |
| `<leader>cv` / `gV` (in blade/php) | Goto Blade view/component under cursor |
| `<leader>cds/cdt/cdi/cdu` | Dependencies (package-info.nvim): show / toggle / install / change version |
| `<leader>ce` / `<C-y>,` (insert) | Expand Emmet abbreviation |

`<leader>cf` formats with **conform** and falls back to the LSP formatter. It
works in normal and visual mode, and it is the only way to format `markdown`
and `gitcommit` — those two filetypes are excluded from format-on-save.

img-clip's `<leader>cp` binding is gone because it was simultaneously a leaf
(paste image) and a prefix (the old `<leader>cp*` package-info keys), so every
press stalled for `timeoutlen`. Pasting images is now command-only via
`:PasteImage`, and package-info moved to `<leader>cd`.

### Snippets (`<leader>cs`)

| Key | Action |
|---|---|
| `<leader>csa` | Add new snippet (Scissors) |
| `<leader>cse` | Edit snippet (Scissors) |

### Local code review (`<leader>cc`)

**code-review.nvim** collects line comments in any buffer and formats them
for an agent; it is the counterpart to atlas, which reviews pull requests.
Use atlas for anything that goes back to GitHub, this for work that is not
pushed yet (untracked files, agent-generated code, scratch buffers).

| Key | Action |
|---|---|
| `<leader>ccc` (n, x) | Add comment on the cursor line or visual range |
| `<leader>ccs` | Show comment at cursor |
| `<leader>ccr` / `<leader>ccx` | Reply to thread / resolve thread |
| `<leader>ccd` | Delete comment at cursor |
| `<leader>ccl` | List review threads |
| `<leader>ccp` | Preview the whole review |
| `<leader>ccy` / `<leader>ccw` | Copy review to clipboard / write to file |
| `<leader>ccX` | Clear all comments |

A count before `<leader>ccc` in normal mode widens the captured context by
that many lines either side of the cursor; a visual selection comments the
whole range instead. The verbs mirror atlas's in-review keys (`c` comment,
`r` reply, `x` resolve, `d` delete).

Every commented line gets a ⟦Uf0189⟧ sign in the gutter, hint-colored so it
reads as a review marker and not as gitsigns' `▎`, and the comment text
appears as end-of-line virtual text on the first line of its range. Both
re-render on buffer entry: the plugin only re-renders indicators for its
file backend, so otherwise they blank out on any `:e`, buffer wipe or
session restore.

Comments live in memory for the session only — nothing is written to the
repo. `<leader>ccy` yanks the whole review to the `+` register as
`path:L12-18: comment` lines, `<leader>ccw` writes a markdown file.
`<leader>ccl` opens the quickfix list (the plugin supports only
telescope/fzf-lua pickers, neither installed). The preview is read-only
here: `q` closes it, and its `:w` handler is removed on open because the
minimal format cannot be parsed back into comments.

### Emmet

**emmet-language-server** attaches to html, blade, astro, svelte, vue, pug,
eruby, htmldjango, jsx/tsx and css/scss/sass/less. Three ways to expand
`div.card>ul>li*3`:

* Completion menu — the abbreviation shows up as an `Emmet Abbreviation`
  item while typing; `<CR>` accepts it.
* `<C-y>,` in insert mode — expands whatever abbreviation ends at the cursor,
  no menu needed (buffer-local, only where the emmet client is attached).
* `<leader>ce` in normal mode — same, for an abbreviation you already typed
  and left.

All three apply the server's snippet, so `<Tab>` / `<S-Tab>` walk the
resulting tabstops. Implementation: `lua/config/actions/emmet.lua`.

The server also detects `<style>` blocks and switches to CSS abbreviations
there, so `init_options.includeLanguages` in `lua/config/lsp/servers.lua` is
deliberately empty — any entry overrides that detection.

### Diagnostics (`<leader>d`)

| Key | Action |
|---|---|
| `[d` / `]d` | Previous / next diagnostic (lspsaga) |
| `[e` / `]e` | Previous / next error |
| `[w` / `]w` | Previous / next warning |
| `<leader>dd` | Toggle diagnostics for buffer |
| `<leader>dv` | Toggle inline virtual lines (lsp_lines) |
| `<leader>df` | Line diagnostics float |
| `<leader>db` | Buffer diagnostics |
| `<leader>dw` | Workspace diagnostics |
| `<leader>ds` | Diagnostics picker |
| `<leader>dt` / `<leader>dT` | Trouble diagnostics / buffer diagnostics |
| `<leader>dq` / `<leader>dl` | Send diagnostics to quickfix / loclist |

### UI / system (`<leader>u`)

| Key | Action |
|---|---|
| `<leader>uu` | Undo tree |
| `<leader>up` / `<leader>uP` | Pack list / Pack update |
| `<leader>ur` | Restart Neovim (`:restart`) |
| `<leader>u?` | Generated memory sheet popup |
| `<leader>ut` | Triforce profile |

#### Notifications (`<leader>un`)

Noice messages and notifications.

| Key | Action |
|---|---|
| `<leader>unp` | Notification picker |
| `<leader>unh` | Message history |
| `<leader>une` | Errors |
| `<leader>unl` | Last message |
| `<leader>und` | Dismiss all |

### Git (`<leader>g`)

Day-to-day: `<leader>gg` opens **Neogit** in a new tab. Stage, commit, push,
fetch all happen there. Inline hunk operations stay on the file with
**gitsigns**.

| Key | Action |
|---|---|
| `<leader>gg` | Open Neogit |
| `]h` / `[h` | Next / previous git hunk |
| `<leader>gs` | Stage hunk |
| `<leader>gr` | Reset hunk |
| `<leader>gp` | Preview hunk |
| `<leader>gb` | Blame line (full) |
| `<leader>gi` | Toggle line blame |
| `<leader>gd` | Diff current file vs HEAD (native difftool) |
| `<leader>gt` | Time machine (agitator) |
| `<leader>gl` | Toggle blame (agitator) |
| `<leader>gB` / `<leader>gD` / `<leader>gL` | advanced-git-search: branches / commits / log content |

### Pull requests & issues (`<leader>ga`)

**atlas.nvim** — GitHub PRs and issues in the editor. Auth comes from the
`gh` CLI (`gh auth login`, scopes `repo` + `read:org`); Jira/GitLab/Bitbucket
are deliberately not configured. Views and searches live in
`lua/plugins/atlas.lua`. Work that is not on GitHub yet goes through
code-review.nvim under `<leader>cc` instead.

| Key | Action |
|---|---|
| `<leader>gaa` | Command picker (`:Atlas`) |
| `<leader>gap` / `<leader>gai` | Pull request / issue dashboard |
| `<leader>gar` | Review a pull request (native AtlasDiff) |
| `<leader>gac` / `<leader>gaI` | Create pull request / issue |
| `<leader>gas` | Search pulls & issues |
| `<leader>gan` / `<leader>gal` | Local review notes / Atlas logs |

Inside the dashboard: `1`–`4` switch views, `S` opens bookmarks, `*` stars an
item, `gd` opens the diff, `gc` checks the branch out, `A` lists actions,
`g?` shows the full buffer-local map. In a review: `]h`/`[h` hunks,
`c` comment, `s` suggestion, `<leader>n` local note, `gs` submit.

### Debugging (`<leader>j`)

Powered by **nvim-dap** + **dap-ui** + **dap-virtual-text**. Adapters and
configs are wired in `lua/util/dap.lua`.

| Key | Action |
|---|---|
| `<F5>` / `<leader>jc` | Continue |
| `<F10>` / `<leader>jo` | Step over |
| `<F11>` / `<leader>ji` | Step into |
| `<S-F11>` / `<leader>ju` | Step out |
| `<leader>jb` / `<leader>jB` | Toggle / conditional breakpoint |
| `<leader>jC` | Clear breakpoints |
| `<leader>jt` | Terminate |
| `<leader>jr` | Toggle REPL |
| `<leader>jv` | Toggle DAP UI |
| `<leader>je` | Eval expression |
| `<leader>jl` | Re-run last config |
| `<leader>jh` | DAP help (`:DapHelp`) |
| `<leader>jP` | Project template (`:DapProjectTemplate`) |

`:DapProjectTemplate` writes a `.vscode/launch.json` skeleton for the
detected stack (PHP/Xdebug, Node).

### AI (`<leader>a`)

CodeCompanion, driven by CLI agents over ACP (claude-agent-acp / codex-acp /
`omp acp`).

| Key | Action |
|---|---|
| `<leader>aa` | Actions menu |
| `<leader>aa` (visual) | Actions menu (selection) |
| `<leader>at` | Toggle chat |
| `<leader>ae` (visual) | Add selection to chat |
| `<leader>ac` | Focus the in-flight chat |
| `<leader>am` | MCPHub |

### Sessions (`<leader>q`)

| Key | Action |
|---|---|
| `<leader>qq` | Quit all |
| `<leader>qn` | Save **named** session for current cwd |
| `<leader>qs` | Load named session |
| `<leader>qx` | Delete named session |
| `<leader>qd` | Stop session recording for this run |

On bare launch (`nvim` with no args, no `+cmd`/`-c`/`-S`/stdin), persistence
prompts:

```
Restore session?
> [fresh start]
  [last session]
  <named-1>
  <named-2>
```

Enter or Esc → fresh start. Auto-saved per-cwd sessions live in
`~/.local/state/nvim/sessions/`. Named sessions live in
`~/.local/state/nvim/named_sessions/<cwd-hash>/`.

## Completion

**blink.cmp** provides completion menu and signature help. Sources, in order:
LSP, path, snippets, buffer.

| Key | Action |
|---|---|
| `<C-space>` | Show / show docs / hide docs |
| `<CR>` | Accept |
| `<Tab>` / `<S-Tab>` | Snippet forward / select next, snippet back / select prev |

LSP capabilities are augmented from blink in `lua/config/lsp.lua`:

```lua
capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
```

## Snippets

Three sources, all loaded by **LuaSnip**:

| Where | Format | Edit with |
|---|---|---|
| `friendly-snippets` | VS Code JSON | (read-only) |
| `~/.config/nvim/luasnippets/<ft>.lua` | LuaSnip Lua | direct edit |
| `~/.config/nvim/snippets/*.json` | VS Code JSON | `:ScissorsAddNewSnippet` / `:ScissorsEditSnippet` |
| `<project>/.luasnippets/*.lua` | LuaSnip Lua | direct edit (project-local) |

Helper command:

```vim
:SnippetHelp
```

## Treesitter

Parser list is in `lua/plugins/treesitter.lua`. Missing parsers install
on-demand the first time you open a supported filetype. Manual update:

```vim
:TSUpdate
```

Folding uses Treesitter (`foldexpr=v:lua.vim.treesitter.foldexpr()`).

## Format & lint

* **conform.nvim** — formatters per filetype. Format-on-save runs except for
  `markdown` and `gitcommit`, so for those two `<leader>cf` (normal and
  visual, conform with an LSP fallback) is the only way to format.
* **nvim-lint** — runs on `BufEnter`, `BufWritePost`, `InsertLeave`. Linters
  per filetype are in `lua/plugins/nvim-lint.lua`.
* **Vim spell checking** — `markdown`, `text`, and `gitcommit` enable the
  built-in spell checker with `spelllang=en_us,fr`; a word valid in either the
  US English or French dictionary is accepted. Dense word-level underlines
  come from `SpellBad`, while markdownlint diagnostics separately report
  Markdown structure/style. The French dictionary lives in
  `stdpath("data")/site/spell`, installed with Neovim's built-in
  `nvim.spellfile` downloader rather than vendored in this config.

## LSP

Native `vim.lsp.config()` + `vim.lsp.enable()` (Neovim 0.12). One server
table per entry in `lua/config/lsp/servers.lua`. mason-lspconfig
`automatic_enable` re-enables them after Mason finishes installing.

GDScript runs over TCP to a live Godot editor (`lua/config/lsp.lua`).
Intelephense reads PHP stubs from `~/.local/share/php-stubs`; manage them
with `:PhpStubsInstall` / `:PhpStubsStatus`.

## Filetypes

Custom filetype detection in `lua/config/options.lua`:

* `*.blade.php` → `blade`
* `.env*` → `dotenv` (uses bash parser via `vim.treesitter.language.register`)
* `.gd` → `gdscript`, `.gdshader` → `gdshader`
* `.tres` / `.tscn` → `godot_resource`
* `aliases*`, `zprofile*` → `bash`

## Health & debugging

```vim
:checkhealth                  " runs everything
:checkhealth pack             " declared binaries on PATH (mine)
:checkhealth vim.pack         " upstream lockfile / install state
:checkhealth vim.lsp          " server state per buffer
:checkhealth nvim-treesitter  " parser state
:LspLog                       " server stderr
:Mason                        " package manager UI
:MasonEnsureList              " what would auto-install
```

Profile startup:

```sh
nvim --startuptime /tmp/nvim.log +qa && tail -30 /tmp/nvim.log
sort -k2 -nr /tmp/nvim.log | head -20    # slowest entries
```

Inspect spec load state:

```vim
:lua vim.print(require("zpack.api").get_plugins())
```

## Conventions

* `<leader>` groups: a/b/c/cc/cd/cs/d/g/ga/j/q/s/t (0.13+)/u/un/w/x/xa/xm.
  Adding a new group? Edit `lua/plugins/which-key.lua` so it shows up in the
  popup. The conditional `t` group is hidden on Neovim 0.12.
* Each plugin file declares everything that plugin needs: src, deps, lazy
  triggers, opts/setup, install hints, keymaps. No global keymap dump.
* `lua/util/` modules are dependency-light: nothing under `util/` should
  `require("plugins.*")`.
* Native APIs are preferred over plugins for things Neovim 0.12 already
  does well (statuscolumn, diagnostics, commenting via `gc`, etc.).

## Rollback

This config is git-tracked. The pre-rewrite state is on `master`:

```sh
cd ~/.config/nvim
git log --oneline                    " see history
git diff master..HEAD                " full diff vs original
git checkout master -- <file>        " restore a single file
git checkout master                  " roll back the whole config
```
