# Tmux Cheatsheet                                                        Prefix: Ctrl-a

## Sessions                                          │     ## Windows
                                                     │
  List / switch ........... prefix + s               │       New window .............. Alt-T
  New session ............. prefix + S               │       Previous window ......... Alt-H
  Kill current session .... prefix + Q               │       Next window ............. Alt-L
  Rename session .......... prefix + $               │       Reorder left ............ Alt-Shift-Left
  Previous session ........ prefix + (               │       Reorder right ........... Alt-Shift-Right
  Next session ............ prefix + )               │       Select by number ........ prefix + 1-9
  Save session (tmuxp) .... prefix + Alt-s           │       Rename window ........... prefix + ,
  Load session (tmuxp) .... prefix + Alt-l           │       List all windows ........ prefix + w
  Detach .................. prefix + D               │       Kill window ............. prefix + d
                                                     │       Kill window (confirm) ... prefix + k
                                                     │       Move to session ......... prefix + M
                                                     │       Move to target .......... prefix + .
                                                     │
## Panes                                             │     ## Copy Mode (Vi)
                                                     │
  Split right ............. prefix + v               │       Enter copy mode ......... prefix + [
  Split below ............. prefix + -               │       Start selection ......... v
  Navigate ................ Ctrl-h/j/k/l             │       Rectangle selection ..... Ctrl-v
  Resize .................. prefix + Alt-arrow       │       Copy to clipboard ....... y
  Zoom toggle ............. prefix + z               │       Copy & paste to prompt .. Y
  Kill pane ............... prefix + x               │       Paste buffer ............ prefix + ]
  Break to new window ..... prefix + !               │       Search forward .......... /
  Floating terminal ....... prefix + f               │       Search backward ......... ?
                                                     │       Exit .................... q / Escape
                                                     │       Mouse select ............ auto-copies
                                                     │
## Yank (normal mode)                                │     ## Open (in copy mode, highlight then)
                                                     │
  Copy command line ....... prefix + y               │       Open file/URL ........... o
  Copy working dir ........ prefix + Y               │       Open in $EDITOR ......... Ctrl-o
                                                     │       Search in Google ........ Shift-s
                                                     │
## Persistence (resurrect + continuum)               │     ## Misc
                                                     │
  Save session ............ prefix + Ctrl-s          │       Cheatsheet .............. prefix + h
  Restore session ......... prefix + Ctrl-r          │       Command prompt .......... prefix + .
  Auto-save ............... every 15 min             │       Reload config ........... prefix + r
  Auto-restore ............ on tmux start            │       Kill server (confirm) ... prefix + K
                                                     │       Screensaver ............. prefix + Escape
## TPM                                               │
                                                     │
  Install plugins ......... prefix + I               │
  Update plugins .......... prefix + U               │
  Remove unused ........... prefix + Alt-u           │
