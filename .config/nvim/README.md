# Neovim config

Personal Neovim 0.12+ config. Native `vim.pack` for plugins, snacks for the
fuzzy stack, lspsaga for LSP UI, blink.cmp for completion, conform/nvim-lint
for formatting/linting, neogit + gitsigns for git, persistence for sessions.

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
  pack.lua                     vim.pack wrapper: spec discovery + lazy loading.
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
  memory_sheet.lua             :MemorySheet quick-reference popup.
  dashboard/                   ASCII art + tips for the Snacks dashboard.
luasnippets/                   User Lua snippets (filetype-named files).
snippets/                      User VS Code-style JSON snippets (Scissors).
```

## First run

```sh
nvim
```

`util.pack.setup()` clones any missing plugins via `vim.pack.add`, eager
plugins load immediately, and lazy plugins register their triggers. On the
first launch that's a one-time clone; subsequent launches are fast.

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
:Pack list          " loaded vs lazy
:Pack update        " native vim.pack update UI
:Pack health        " :checkhealth pack + vim.pack
:Pack log           " :checkhealth vim.pack (lockfile state)
```

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
  keys = { { "<leader>x", "<cmd>Foo<cr>" } }, -- table form is a trigger
  lazy = true,                                -- force lazy with no trigger

  -- One of these initializes the plugin:
  opts = { ... },                             -- passed to require(main).setup
  setup = function(spec) ... end,             -- full custom init
  config = function(spec, opts) ... end,      -- if you need both opts and code

  -- Optional:
  main = "module.name",                       -- override module-name inference
  priority = 100,                             -- higher → earlier eager load
  build = "<cmd>" or function(spec) end,      -- runs on PackChanged
  init = function(spec) end,                  -- runs at startup, even if lazy
  cond = function() return ... end,           -- skip load if false
  enabled = false,                            -- skip entirely
  install = {                                 -- consumed by :checkhealth pack
    binaries = { "..." },
    packages = { npm = {...}, composer = {...} },
    notes = { "..." },
  },

  -- keys = function(map) ... end is a load-time callback (NOT a lazy trigger)
}
```

After saving, restart Neovim — the new plugin will be cloned by `vim.pack.add`
on next startup.

### Removing a plugin

Delete `lua/plugins/<name>.lua`, restart, then `:Pack update` to prune the
clone from disk (or `rm -rf ~/.local/share/nvim/site/pack/core/opt/<dir>`).

## Keymaps

Leader is `<Space>`, local-leader is `,`. All groups are described in
`lua/plugins/which-key.lua` and shown by which-key on `<Space>`.

### Files & search (`<leader>f`, `<leader>s`)

| Key | Action |
|---|---|
| `<leader><space>` | Find files |
| `<leader>/` | Live grep |
| `<leader>ff` / `<leader>sf` | Find files |
| `<leader>fb` / `<leader>sb` | Buffers |
| `<leader>fo` / `<leader>so` | Recent files |
| `<leader>fe` | Snacks file explorer |
| `<leader>fg` | Grep in current file's directory |
| `<leader>sg` | Live grep |
| `<leader>sw` | Grep word under cursor |
| `<leader>sh` | Help tags |
| `<leader>ss` | Document symbols |
| `<leader>sd` | Diagnostics picker |

In the grep picker, type `<query> -- <glob> !<exclude>` to filter, e.g.
`TODO -- *.lua !test/*`. `<C-q>` sends results to the quickfix list.

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

`<leader>x` is the nav/list root.

| Key | Action |
|---|---|
| `<leader>xq` | Toggle quickfix |
| `<leader>xl` | Toggle location list |
| `]q` / `[q` | Next/prev quickfix item |
| `]l` / `[l` | Next/prev loclist item |
| `<leader>xR` | Replace-in-files for quickfix entries (interactive) |
| `<leader>xa` | Set arglist to current file only |
| `<leader>xs` | Show arglist (picker) |
| `<leader>xn` / `<leader>xp` | Next / previous arg |
| `<leader>xf` / `<leader>xL` | First / last arg |
| `<leader>xe` | Add current file to arglist |
| `<leader>xd` | Remove file from arglist |

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
| `<leader>cf` | Format buffer (conform) |
| `<leader>co` | Outline |
| `<leader>ci` / `<leader>cO` | Incoming / outgoing calls |
| `<leader>ch` | Toggle inlay hints |
| `<leader>cl` | LSP info |
| `<leader>cR` | Restart LSP |
| `<leader>cL` | LSP log |
| `<leader>cn` | Generate annotation (neogen) |
| `<leader>cT` | Trouble LSP view |
| `<leader>cv` / `gV` (in blade/php) | Goto Blade view/component under cursor |
| `<leader>cp` | Paste image from clipboard (img-clip) |
| `<leader>cps/cpt/cpi/cpu` | package-info.nvim show/toggle/install/upgrade |

### Snippets (`<leader>cs`)

| Key | Action |
|---|---|
| `<leader>csa` | Add new snippet (Scissors) |
| `<leader>cse` | Edit snippet (Scissors) |

### Diagnostics (`<leader>ux`)

| Key | Action |
|---|---|
| `[d` / `]d` | Previous / next diagnostic (lspsaga) |
| `[e` / `]e` | Previous / next error |
| `[w` / `]w` | Previous / next warning |
| `<leader>uxo` | Line diagnostics float |
| `<leader>uxb` | Buffer diagnostics |
| `<leader>uxw` | Workspace diagnostics |
| `<leader>uxd` | Toggle diagnostics for buffer |
| `<leader>uxl` / `<leader>uxq` | Send diagnostics to loclist / qf |
| `<leader>uxt` / `<leader>uxT` | Trouble diagnostics / buffer diagnostics |
| `<leader>uxQ` / `<leader>uxL` | Trouble qflist / loclist |
| `<leader>ul` | Toggle inline diagnostics (lsp_lines) |

### UI / system (`<leader>u`)

| Key | Action |
|---|---|
| `<leader>uu` | Undo tree |
| `<leader>uM` | Toggle render-markdown |
| `<leader>up` / `<leader>uP` | Pack list / Pack update |
| `<leader>ur` | Restart Neovim (`:restart`) |
| `<leader>u?` | Memory sheet popup |
| `<leader>um` | MCPHub |
| `<leader>uh` / `<leader>un` | Noice history / dismiss |
| `<leader>ui` / `<leader>ue` / `<leader>uN` | Noice picker / errors / last |

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

Claude Code integration.

| Key | Action |
|---|---|
| `<leader>ac` | Toggle Claude |
| `<leader>af` | Focus Claude |
| `<leader>ar` | Resume |
| `<leader>aC` | Continue |
| `<leader>am` | Select model |
| `<leader>ab` | Add current buffer |
| `<leader>as` (visual) | Send selection |
| `<leader>aD` / `<leader>ad` | Accept / deny diff |

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
  `markdown` and `gitcommit`. Manual: `<leader>cf`.
* **nvim-lint** — runs on `BufEnter`, `BufWritePost`, `InsertLeave`. Linters
  per filetype are in `lua/plugins/nvim-lint.lua`.

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
:lua local p = require("util.pack"); for _,s in ipairs(p.specs()) do print((p.is_loaded(s.name) and "✓" or "·").." "..s.name) end
```

## Conventions

* `<leader>` groups: a/b/c/cs/f/g/j/q/s/u/ux/w/x/xm. Adding a new group?
  Edit `lua/plugins/which-key.lua` so it shows up in the popup.
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
