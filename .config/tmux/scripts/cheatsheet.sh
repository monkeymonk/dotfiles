#!/usr/bin/env bash
set +H 2>/dev/null

# Catppuccin Mocha palette
R="\e[0m"; B="\e[1m"; D="\e[2m"
MAU="\e[38;2;203;166;247m"
GRN="\e[38;2;166;227;161m"
SUB="\e[38;2;166;173;200m"
PNK="\e[38;2;245;194;231m"
SRF="\e[38;2;69;71;90m"
OVR="\e[38;2;108;112;134m"

# Layout:  [2 margin][45 left]│[46 right]  = 94 visible chars

row() {
  local ld="$1" lk="$2" rd="$3" rk="$4"
  local lgap=$((41 - ${#ld} - ${#lk}))
  local rgap=$((40 - ${#rd} - ${#rk}))
  [ $lgap -lt 1 ] && lgap=1
  [ $rgap -lt 1 ] && rgap=1
  printf "  "
  printf "  ${SUB}%s${R}%*s${GRN}%s${R}  " "$ld" "$lgap" "" "$lk"
  printf "${SRF}│${R}"
  printf "     ${SUB}%s${R}%*s${GRN}%s${R} " "$rd" "$rgap" "" "$rk"
  printf "\n"
}

rrow() {
  local rd="$1" rk="$2"
  local rgap=$((40 - ${#rd} - ${#rk}))
  [ $rgap -lt 1 ] && rgap=1
  printf "  %45s" ""
  printf "${SRF}│${R}"
  printf "     ${SUB}%s${R}%*s${GRN}%s${R} " "$rd" "$rgap" "" "$rk"
  printf "\n"
}

lrow() {
  local ld="$1" lk="$2"
  local lgap=$((41 - ${#ld} - ${#lk}))
  [ $lgap -lt 1 ] && lgap=1
  printf "  "
  printf "  ${SUB}%s${R}%*s${GRN}%s${R}  " "$ld" "$lgap" "" "$lk"
  printf "\n"
}

hdr() {
  printf "  "
  printf "  ${B}${MAU}  %s${R}%*s" "$1" "$((41 - ${#1} - 2))" ""
  printf "  ${SRF}│${R}"
  printf "     ${B}${MAU}  %s${R}%*s" "$2" "$((40 - ${#2} - 2))" ""
  printf " \n"
}

lhdr() {
  printf "  "
  printf "  ${B}${MAU}  %s${R}%*s" "$1" "$((41 - ${#1} - 2))" ""
  printf "  ${SRF}│${R}\n"
}

sep() {
  printf "  ${SRF}"
  for ((i=0;i<45;i++)); do printf '─'; done
  printf '┼'
  for ((i=0;i<46;i++)); do printf '─'; done
  printf "${R}\n"
}

lsep() {
  printf "  ${SRF}"
  for ((i=0;i<45;i++)); do printf '─'; done
  printf "┘${R}\n"
}

blank() {
  printf "  %45s${SRF}│${R}\n" ""
}

clear
printf "  ${B}${PNK}╔"; for ((i=0;i<90;i++)); do printf '═'; done; printf "╗${R}\n"
printf "  ${B}${PNK}║%35s%s%40s║${R}\n" "" "Tmux Cheatsheet" ""
printf "  ${B}${PNK}║%36s%s%40s║${R}\n" "" "Prefix: Ctrl-a" ""
printf "  ${B}${PNK}╚"; for ((i=0;i<90;i++)); do printf '═'; done; printf "╝${R}\n"
blank
hdr "Sessions" "Windows"
sep
row "List / switch"    "prefix + s"     "New window"       "Alt-T"
row "New session"      "prefix + S"     "Previous window"  "Alt-H"
row "Kill session"     "prefix + Q"     "Next window"      "Alt-L"
row "Rename session"   "prefix + \$"    "Reorder left"     "Alt-Shift-Left"
row "Previous session" "prefix + ("     "Reorder right"    "Alt-Shift-Right"
row "Next session"     "prefix + )"     "Select by number" "prefix + 1-9"
row "Save (tmuxp)"     "prefix + Alt-s" "Rename window"    "prefix + ,"
row "Load (tmuxp)"     "prefix + Alt-l" "List all windows" "prefix + w"
row "Edit (tmuxp)"     "prefix + Alt-S" "Kill window"      "prefix + d"
row "Detach"           "prefix + D"     "Kill (confirm)"   "prefix + k"
rrow                                    "Move to session"  "prefix + M"
blank
hdr "Panes" "Copy Mode (Vi)"
sep
row "Split right"       "prefix + v"         "Enter copy mode"   "prefix + ["
row "Split below"       "prefix + -"         "Start selection"   "v"
row "Navigate"          "Ctrl-h/j/k/l"       "Rectangle select"  "Ctrl-v"
row "Resize"            "prefix + Alt-arrow"  "Copy to clipboard" "y"
row "Zoom toggle"       "prefix + z"         "Copy & paste"      "Y"
row "Kill pane"         "prefix + x"         "Paste buffer"      "prefix + ]"
row "Break to window"   "prefix + !"         "Search forward"    "/"
row "Floating terminal" "prefix + f"         "Search backward"   "?"
rrow                                         "Exit"              "q / Escape"
blank
hdr "Yank (normal mode)" "Open (copy mode, select first)"
sep
row "Copy command line" "prefix + y" "Open file/URL"    "o"
row "Copy working dir"  "prefix + Y" "Open in \$EDITOR" "Ctrl-o"
rrow                                 "Search in Google" "Shift-s"
blank
hdr "Persistence" "Misc"
sep
row "Save session"    "prefix + Ctrl-s" "Cheatsheet"    "prefix + h"
row "Restore session" "prefix + Ctrl-r" "Command prompt" "prefix + ."
row "Auto-save"       "every 15 min"    "Reload config" "prefix + r"
row "Auto-restore"    "on tmux start"   "Kill server"   "prefix + K"
rrow                                    "Screensaver"   "prefix + Escape"
blank
lhdr "TPM"
lsep
lrow "Install plugins" "prefix + I"
lrow "Update plugins"  "prefix + U"
lrow "Remove unused"   "prefix + Alt-u"
echo ""
printf "%36s${D}${OVR}Press any key to close${R}\n" ""

read -rsn1
