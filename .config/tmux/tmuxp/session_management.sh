#!/bin/bash

# List options: View sessions, switch, edit, rename, delete, save
OPTION=$(echo -e "Switch\nEdit\nRename\nClose\nDelete\nSave" | fzf --header="Select an action")

case "$OPTION" in
"Switch")
	~/.config/tmux/tmuxp/session_switch.sh
	;;
"Edit")
	~/.config/tmux/tmuxp/session_edit.sh
	;;
"Rename")
	~/.config/tmux/tmuxp/session_rename.sh
	;;
"Close")
	~/.config/tmux/tmuxp/session_close.sh
	;;
"Delete")
	~/.config/tmux/tmuxp/session_delete.sh
	;;
"Save")
	~/.config/tmux/tmuxp/session_save.sh
	;;
*)
	echo "No valid option selected."
	;;
esac
