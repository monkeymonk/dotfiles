# shells/zsh/options.zsh

[[ -n "${ZSH_VERSION-}" ]] || return 0

# History
setopt HIST_IGNORE_DUPS       # Don't record duplicate entries
setopt HIST_IGNORE_SPACE      # Don't record entries starting with space
setopt HIST_REDUCE_BLANKS     # Remove extra blanks from history
setopt SHARE_HISTORY          # Share history between sessions
HISTORY_IGNORE="(ls|cd|pwd|exit|sudo reboot|history|cd -|cd ..)"

# Directory navigation
setopt AUTO_CD                # cd by typing directory name
setopt AUTO_PUSHD             # Push directories onto stack
setopt PUSHD_IGNORE_DUPS      # Don't push duplicates
setopt PUSHD_SILENT           # Don't print stack after pushd/popd

# Completion
setopt COMPLETE_IN_WORD       # Complete from cursor position
setopt ALWAYS_TO_END          # Move cursor to end after completion

# Globbing
setopt EXTENDED_GLOB          # Extended glob patterns
setopt NO_CASE_GLOB           # Case-insensitive globbing

# Safety
setopt NO_CLOBBER             # Don't overwrite files with > (use >|)
setopt NO_BEEP                # No beeping
