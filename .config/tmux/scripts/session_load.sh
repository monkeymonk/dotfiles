#!/usr/bin/env bash
# Load a tmuxp session from ~/.tmuxp/ using fzf
CONFIG=$(ls -1 ~/.tmuxp/*.yaml 2>/dev/null | xargs -I{} basename {} .yaml | fzf --prompt="Load session: " --height=40% --reverse)

[ -z "$CONFIG" ] && exit 0

tmuxp load -y "$HOME/.tmuxp/${CONFIG}.yaml" 2>/dev/null
