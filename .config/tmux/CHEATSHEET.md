# Tmux key bindings

The help popup is a **live, searchable index of the bindings tmux has actually
loaded** — not a hand-maintained table.

## Open it

```
prefix + h            # prefix is C-a
```

A floating popup shows every annotated binding as a **category-grouped grid**
(columns adapt to the popup width). Type to fuzzy-filter — a query matches a
whole grid row. `Esc` or `Ctrl-c` closes it. Selecting a row does nothing: this
is an informational panel, it never runs the binding.

## How it works

- `scripts/cheatsheet.sh` reads bindings from `tmux list-keys -N` when opened.
  **tmux is the source of truth** — there is no second list to maintain.
- Each of my bindings carries a note of the form:

  ```
  bind-key -N "Category | Description" <key> <command>
  ```

  The script splits the note on ` | ` into a **category** and a **description**.
- The prefix is detected dynamically, so prefix-table shortcuts render as
  `C-a h` and root-table (global) shortcuts render bare, e.g. `M-T`.

## Add a binding to the index

Annotate it in `tmux.conf` and reload (`prefix + r`):

```
bind-key -N "Panes | Swap with the marked pane" b swap-pane
```

It appears in the popup automatically, grouped under its category. The popup
orders groups as: `Sessions`, `Windows`, `Navigation`, `Panes`, `Copy mode`,
`Persistence`, `Configuration`, `Utilities`, `Plugins`, `Workmux`, `Help`
(anything else sorts last). Reuse one of these categories.

## Notes

- Only bindings annotated with the `Category | Description` convention appear.
  The dozens of tmux/plugin **default** bindings that ship their own plain notes
  are intentionally excluded, so the index stays curated rather than a wall of
  keys. To surface a default, annotate it (see below).
- The genuinely useful defaults (zoom, swap/resize pane, list/rename
  session+window, copy mode, …) are annotated in `tmux.conf` so they still show
  up, grouped.
- Plugin keys (`tmux-resurrect` save/restore, `tmux-floax`, `tmux-yank`, TPM)
  are re-declared **after** the `run tpm` line — that is the only place a note
  survives plugin loading. They restate each plugin's own binding verbatim; if a
  plugin renames its scripts, update those lines to match.
- `copy-mode-vi` bindings appear only if I have explicitly annotated them.

## Workmux

| Binding        | Action                                    |
| -------------- | ----------------------------------------- |
| `prefix + W`   | Open the Workmux agent dashboard (popup)  |
| `prefix + C-w` | Toggle the live agent status sidebar      |

Both are annotated `Workmux | …`, so they also appear in `prefix + h`.

### Sidebar + tmux-resurrect

`workmux sidebar` adds a narrow pane to the left of every window. tmux-resurrect
saves those panes, and on restart continuum restores them as dead empty shells
(the workmux process isn't restored) — leftover sidebar splits.

`scripts/sidebar_cleanup.sh` (wired to a `client-attached` hook) fixes this: once
per server, after a restore, it removes leftover sidebar columns — but only while
no live sidebar is active (`@workmux_sidebar_enabled`), and only panes matching
the sidebar signature (full-height, left-edge, narrow ≤50 cols, bare shell, in a
multi-pane window). Verified safe against the tmuxp layouts, none of which use a
narrow-left split. If you move the sidebar to `position: top`, update the script.
