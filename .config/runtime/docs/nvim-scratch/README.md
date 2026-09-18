# nvim-scratch

Persistent Neovim scratchpad service with on-demand UI attachment. One headless Neovim server per named scratchpad, surviving shell/tmux/pane closure; UI clients detach without killing the server.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                      Service (core)                     │
│  Headless nvim instance per NAME (--headless --listen) │
│  Survives shell/tmux closure; persistent state          │
│  Socket dir: $XDG_RUNTIME_DIR/nvim-scratch/ (0700)      │
│  State:  ~/.local/state/nvim-scratch/NAME.md (markdown)│
│  Shada:  ~/.cache/nvim-scratch/NAME/main.shada         │
└─────────────────────────────────────────────────────────┘
              ↓ (RPC attach/open/eval/stop)
┌─────────────────────────────────────────────────────────┐
│            UI (tmux helper, when present)               │
│  nvim-scratch-toggle: floating pane/popup presentation  │
│  Handles NVIM_SCRATCH_SURFACE (auto/float/popup)       │
│  Handles NVIM_SCRATCH_SIZE (default 80x70%)            │
│  :detach → UI closes, server runs                       │
│  :q → server quits (same as normal nvim)               │
└─────────────────────────────────────────────────────────┘
```

**Service vs. UI Boundary:**
- **Service (tmux-independent):** One persistent headless server per instance, spawned by `nvim-scratch` attach/open commands, survives all shell/tmux closure.
- **UI (tmux-only):** Presentation is owned by `${XDG_CONFIG_HOME:-$HOME/.config}/tmux/scripts/nvim-scratch-toggle`, handling pane/popup geometry and lifecycle. The `toggle` and `close` commands forward to this script for backward compatibility.

## Command Reference

### attach (default)

```sh
nvim-scratch attach [NAME]
```

Ensure server for NAME exists, attach a UI client in the current terminal (blocking). NAME defaults to `scratch`.

**Lifecycle:**
- Server created on first invocation, reused afterward.
- Closing the pane/client: `:detach` (builtin Ex command) or just closing the window detaches the UI without stopping the server.
- `:q` inside the client quits the server (same as in any Neovim session).

### open

```sh
nvim-scratch open [--name NAME] FILE...
nvim-scratch open NAME -- FILE...
```

Ensure server for NAME, open FILE(s) via `--remote` without attaching a UI.

**Path handling:** Relative paths are converted to absolute paths using the caller's working directory.

**Examples:**
```sh
nvim-scratch open README.md
nvim-scratch open --name notes 'file with spaces.md'
nvim-scratch open notes -- file.md other.md
```

### eval

```sh
nvim-scratch eval [NAME] EXPR
```

Execute a Vimscript expression in an already-running server and print the result. Never spawns a server. Returns exit code 0 on success. When NAME is not running, exits with rc=1 and error message: `NAME is not running — eval never spawns; use open or attach first`.

**Example:**
```sh
nvim-scratch eval scratch 'getcwd()'
nvim-scratch eval 'getcwd()'  # defaults to scratch
```
### stop

```sh
nvim-scratch stop [NAME]
```

Quit the server for NAME, remove its socket.

### status

```sh
nvim-scratch status
```

List all socket entries (both live and stale) in the socket directory (one line per instance). Stale sockets (files with no listener) are pruned by lifecycle commands; `status` does not clean them.

### doctor

```sh
nvim-scratch doctor
```

Environment diagnostics and per-instance health check (socket state, permissions, paths).

### toggle (tmux-only)

```sh
nvim-scratch toggle [NAME]
```

Toggle a floating pane/popup running `attach`. Forwards to `${XDG_CONFIG_HOME:-$HOME/.config}/tmux/scripts/nvim-scratch-toggle toggle`.

### close (tmux-only)

```sh
nvim-scratch close [NAME]
```

Close the UI surface if open; no-op otherwise. Forwards to tmux helper.

## NAME Syntax

Instances are named with alphanumeric, underscore, dot, and hyphen characters (`[A-Za-z0-9_.-]+`), except the reserved names `.` and `..`. The default instance is `scratch`. Each NAME gets its own:
- Socket: `$XDG_RUNTIME_DIR/nvim-scratch/NAME.sock`
- State file: `~/.local/state/nvim-scratch/NAME.md`
- Shada: `~/.cache/nvim-scratch/NAME/main.shada`

## Attach/Detach/Quit Lifecycle

| Action | Effect |
|--------|--------|
| `:detach` (Ex command) | Closes the UI client; server continues running |
| Close pane/window | Same as `:detach` |
| `:q` or `:qa` | Quits the server (normal Neovim behavior) |
| `:wq` | Writes and quits the server |

The key distinction: there is no visual difference between `:detach` and `:q`; the command you type decides whether the server lives on or exits.

## open Behavior

`nvim-scratch open` uses the caller's working directory to resolve relative paths to absolute paths before sending them to the server via `--remote`. This allows file opening from any directory without navigating inside the scratchpad first.

## eval Behavior

`nvim-scratch eval` requires a live server (never spawns one). Returns the expression result to stdout and the Neovim exit code (0 = success). When the server is not running, returns rc=1 and an error message; does not spawn.

**Live-server check:** Sends an RPC probe; socket files without listeners refuse connection immediately (no hang risk). When `timeout` is available, a 2-second timeout is added as a courtesy.

## Storage

### Socket Directory

- **Primary:** `$XDG_RUNTIME_DIR/nvim-scratch/` (mode 0700, user-only)
- **Fallback:** `${TMPDIR:-/tmp}/nvim-scratch-$(id -u)/` (when `XDG_RUNTIME_DIR` is unset)

Sockets are msgpack-RPC endpoints exposing `nvim_exec_lua` — arbitrary code execution for whoever can connect. The socket directory is only traversed/probed when it is:
1. **Not a symlink** (symlinks are rejected)
2. **Mode 0700** (not looser like 0755 or 0777)
3. **Owned by the current UID** (no cross-user access)

An existing directory never gets "fixed" into trust; a symlink, mode mismatch, or owner mismatch fails closed instead of being silently repaired (see fail-closed implementation below).

### State File

- **Path:** `~/.local/state/nvim-scratch/NAME.md` (or `${XDG_STATE_HOME:-...}`)
- **Format:** Markdown (default extension `.md`)
- **Override:** `NVIM_SCRATCH_FILE=path nvim-scratch ...` (single invocation only)

### Shada (Marks/Registers)

- **Path:** `~/.cache/nvim-scratch/NAME/main.shada`
- **Purpose:** Dedicated shada file so scratchpads never clobber marks/registers of ordinary Neovim sessions
- **Used:** Automatically accessed by server when running; marks and registers are preserved across client sessions

## Locking & Startup

**Liveness decision serialization:** Every `attach`/`open` decision and every `stop` is serialized on a per-NAME mkdir-based lock (exclusive directory creation) to prevent concurrent starts/stops from stepping on each other.

### Stale Socket Cleanup

`nvim-scratch` probes every socket before reusing it. A socket file that exists but no listener responds is removed automatically:

```sh
ns_probe_live()    # RPC probe with optional timeout
ns_stale()         # Detects dead socket + removes it
ns_ensure_server() # Acquires lock → probes → spawns if needed
```

### Startup Readiness

After spawning, the script waits up to 5 seconds for the server to become ready (50 retries × 100ms). If not ready, startup fails with stderr tail from the spawn log.

### Lock Recovery

If a lock is held by another process, the script waits up to 5 seconds for release. If still held after 5 seconds and the lock directory is ≥60 seconds old (abandoned by a crashed invocation), recovery is attempted and the lock is acquired. Otherwise, startup fails.

## Tmux Integration

### tmux Helper Script

`${XDG_CONFIG_HOME:-$HOME/.config}/tmux/scripts/nvim-scratch-toggle` owns all tmux-side presentation:

- **`NVIM_SCRATCH_SURFACE`** (`auto`/`float`/`popup`): Presentation tier
  - `auto`: Try floating pane (tmux 3.7 `new-pane`), fall back to popup
  - `float`: Hard-require floating pane; fail if unavailable
  - `popup`: Hard-require popup
- **`NVIM_SCRATCH_SIZE`** (default `80x70`): Percent of window dimensions

### Binding

```sh
bind-key -N "Utilities | Toggle the nvim scratchpad" e run-shell "~/.config/tmux/scripts/nvim-scratch-toggle toggle"
```

Press `prefix + e` to toggle the scratchpad float/popup.

### Foreground Wrapper (resurrect Compatibility)

The pane's foreground command is always `nvim-scratch attach NAME`, never a raw `nvim --server ... --remote-ui`.

**Why:** tmux-resurrect (`@resurrect-strategy-nvim 'session'`) treats the foreground command as a restoration target. A raw `--remote-ui` invocation would be restored after a reboot as a UI client pointed at a socket that no longer exists (exit 1). By keeping the wrapper in the foreground, `nvim-scratch attach` transparently re-attaches (or respawns) instead.

### Cleanup Hook

The tmux config includes a `client-detached` hook that closes the surface when a client detaches:

```sh
set-hook -g client-detached 'run-shell -b "… ; ~/.config/tmux/scripts/nvim-scratch-toggle close"'
```

**Floating pane:** Closed on client detach, preventing tmux-resurrect (via continuum) from saving a pane it cannot restore.

**Popup:** The hook still runs, but popup close is a no-op for popups (they are modal overlays bound to the client, not persistent panes), so they naturally disappear when the client closes.

## Neovim Integration

### g:scratchpad

When a server is spawned, it receives `--cmd "let g:scratchpad='NAME'"`, setting `vim.g.scratchpad` to the instance name.

### Autocmd Fixup

Neovim config (`lua/config/autocmds.lua`) includes:

```lua
local function fixup_scratchpad_buffer(buf)
    if not vim.g.scratchpad then
        return  -- Not a scratchpad instance
    end
    local name = vim.api.nvim_buf_get_name(buf)
    if not name:match("nvim%-scratch") or not name:match("%.md$") then
        return  -- Not a scratchpad buffer
    end
    if vim.bo[buf].filetype ~= "markdown" then
        vim.bo[buf].filetype = "markdown"
    end
    -- Custom keymap for scratchpad q register (macro recording)
    vim.keymap.set("n", "q", function()
        -- lualine refresh + macro recording logic
    end, { buffer = buf, expr = true, nowait = true, desc = "Toggle macro recording in q register" })
end

autocmd({ "BufReadPost", "BufNewFile", "BufEnter" }, {
    group = group_scratchpad,
    pattern = "*.md",
    callback = function(args)
        fixup_scratchpad_buffer(args.buf)
    end,
})
```

This ensures markdown files opened in a scratchpad instance get proper filetype detection and a `q` keymap for macro recording.

### Persistence Suppression

The server launches with `--cmd "let g:scratchpad='NAME'"` to:
1. Tag the instance for the user's config (allows conditional logic based on `vim.g.scratchpad`)
2. Suppress persistence.nvim's "Restore session?" prompt (persistence.nvim guards with `launched_bare()`, which checks for `--cmd`)

## Shell Plugin & Stale Indicator

### Plugin Registration

`plugins/nvim-scratch.sh` registers a lazy resolver for `RUNTIME_SCRATCH_RUNNING`:

```sh
_runtime_resolve_scratch_running() {
    # Counts actual .sock files (never probes/spawns)
    # Sets RUNTIME_SCRATCH_RUNNING to 'yes' or 'no'
}

runtime_plugin_nvim_scratch() {
    has_cmd nvim || return 0
    command -v alx >/dev/null 2>&1 && alias scratch='nvim-scratch' ...
    ctx_set_lazy RUNTIME_SCRATCH_RUNNING _runtime_resolve_scratch_running plugin
}

hook_register setup runtime_plugin_nvim_scratch
```

### Stale Indicator Tradeoff

`RUNTIME_SCRATCH_RUNNING` counts actual socket nodes in the runtime directory by iterating through the directory. It never spawns a server or probes for liveness.

**Tradeoff:** In rare cases where only stale socket files remain (from crashed servers), the indicator reports `yes` even though no server is actually live. These stale sockets are cleaned automatically by the next `attach`, `open`, or `stop` lifecycle command. This tradeoff keeps shell startup fast (no RPC probes during shell load).

## Environment Variables (Core)

These are owned by the nvim-scratch script and should not be overridden by the shell plugin (the server outlives the shell that spawned it):

| Variable | Default | Purpose |
|----------|---------|---------|
| `NVIM_SCRATCH_NVIM` | `nvim` | Binary path |
| `NVIM_SCRATCH_NVIM_ARGS` | `""` | Extra args (word-split) |
| `NVIM_SCRATCH_FILE` | unset | State file override (single invocation only; when unset, `$NVIM_SCRATCH_STATE_DIR/NAME.md`) |
| `NVIM_SCRATCH_STATE_DIR` | `${XDG_STATE_HOME:-$HOME/.local/state}/nvim-scratch` | State directory override |

## Environment Variables (tmux Helper)

Owned by the tmux helper script (`nvim-scratch-toggle`):

| Variable | Default | Purpose |
|----------|---------|---------|
| `NVIM_SCRATCH_SURFACE` | `auto` | Presentation tier (`auto`/`float`/`popup`) |
| `NVIM_SCRATCH_SIZE` | `80x70` | Percent of window |

## Troubleshooting

### Status & Doctor

```sh
nvim-scratch status        # List live and stale socket entries
nvim-scratch doctor        # Full diagnostics
```

### Common Issues

**Socket path too long (>100 chars):**
- Unix domain socket paths (sun_path) are capped near 104 bytes on many platforms.
- A silently truncated path could hand two different names the same clipped socket.
- The script refuses paths >100 chars loudly rather than silently failing.
- **Fix:** Use shorter instance names, or shorten `$XDG_RUNTIME_DIR`. If the fallback directory is active (when `$XDG_RUNTIME_DIR` is unset), shorten `$TMPDIR` instead.

**Socket directory fails trust checks:**
- Socket directories must be non-symlink, mode 0700 (user-only), and owned by the current UID.
- Existing symlinks, mode 0755/0777, or wrong ownership are rejected (never silently "fixed").
- **Fix:** Run `nvim-scratch doctor` to display diagnostics for all instances; its output identifies which socket directory each uses. Correct the specific trust failure for the relevant directory: mode 0700, non-symlink, and current-user ownership. (Do not attempt to fix the parent directory; the socket directory itself must meet these requirements.)

**Socket owned by a different UID:**
- Cross-user sockets are rejected by `nvim-scratch`.
- **Fix:** Confirm that no valid server process owns the socket (e.g., via `ps aux` or `lsof`), then resolve the ownership conflict outside nvim-scratch (remove the stale socket file or correct its owner). Lifecycle commands reject but do not remove sockets owned by other UIDs.

**Stale socket after server crash:**
- The socket file remains but no listener responds.
- **Fix:** Stale sockets are detected and removed by the next `attach`, `open`, or `stop` command. Run any of these commands to clean them up automatically.

**Startup fails within 5 seconds:**
- Server did not become ready to accept RPC.
- **Check:** Run `nvim-scratch doctor` to display diagnostics for all instances; its output identifies which socket directory is being used. Then inspect `NAME.log` in that directory for spawn errors.
- **Common causes:** Missing or broken Neovim binary (`$NVIM_SCRATCH_NVIM`), or broken Neovim config (e.g., syntax error in `~/.config/nvim/init.lua`).

### Eval Against Non-Live Server

`nvim-scratch eval` requires a live server:

```sh
nvim-scratch eval my-instance 'getcwd()'
# error: nvim-scratch: 'my-instance' is not running — eval never spawns a server; use 'open' or 'attach' first
```

**Fix:** Run `nvim-scratch attach my-instance` first to start the server.

## Implementation File Map

| File | Purpose |
|------|---------|
| `~/.config/runtime/scripts/nvim-scratch` | Core service script (attach/open/eval/stop/status/doctor) |
| `~/.config/runtime/plugins/nvim-scratch.sh` | Shell plugin (alias registration, RUNTIME_SCRATCH_RUNNING lazy resolver) |
| `~/.config/tmux/scripts/nvim-scratch-toggle` | tmux helper (float/popup presentation, NVIM_SCRATCH_SURFACE/NVIM_SCRATCH_SIZE) |
| `~/.config/tmux/tmux.conf` | Binding `prefix + e` to toggle command |
| `~/.config/nvim/lua/config/autocmds.lua` | Scratchpad buffer fixup (filetype, macro recording keymap) |
| `~/.local/state/nvim-scratch/NAME.md` | State file (markdown notes per scratchpad) |
| `~/.cache/nvim-scratch/NAME/main.shada` | Marks/registers (dedicated per scratchpad) |
| `$XDG_RUNTIME_DIR/nvim-scratch/NAME.sock` | Service socket (in 0700 directory) |
| `$XDG_RUNTIME_DIR/nvim-scratch/NAME.lock` | Lifecycle lock (temporary during startup/shutdown) |
| `$XDG_RUNTIME_DIR/nvim-scratch/NAME.log` | Spawn log (diagnostics) |
