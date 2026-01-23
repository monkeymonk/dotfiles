# shells/zsh/clipboard.zsh

[[ -n "${ZSH_VERSION-}" ]] || return 0

# Cross-platform clipboard command
clipboard() {
  # Wayland (Linux)
  if [[ -n "$WAYLAND_DISPLAY" ]] && command -v wl-copy >/dev/null; then
    wl-copy
    return
  fi

  # X11
  if [[ -n "$DISPLAY" ]]; then
    if command -v xclip >/dev/null; then
      xclip -selection clipboard
      return
    elif command -v xsel >/dev/null; then
      xsel --clipboard --input
      return
    fi
  fi

  # macOS
  if command -v pbcopy >/dev/null; then
    pbcopy
    return
  fi

  # Windows / WSL
  if command -v clip.exe >/dev/null; then
    clip.exe
    return
  fi

  # Cygwin
  if command -v putclip >/dev/null; then
    putclip
    return
  fi

  # OSC52 fallback (SSH/tmux)
  local data; data=$(cat | base64 | tr -d '\r\n')
  printf '\e]52;c;%s\a' "$data"
}

clipboard_get() {
  if [[ -n "$WAYLAND_DISPLAY" ]] && command -v wl-paste >/dev/null; then
    wl-paste
  elif [[ -n "$DISPLAY" ]] && command -v xclip >/dev/null; then
    xclip -selection clipboard -o
  elif [[ -n "$DISPLAY" ]] && command -v xsel >/dev/null; then
    xsel --clipboard --output
  elif command -v pbpaste >/dev/null; then
    pbpaste
  elif command -v powershell.exe >/dev/null; then
    powershell.exe Get-Clipboard | tr -d '\r'
  fi
}

# Hook into zsh-vi-mode after it's loaded
function zvm_after_init() {
  function zvm_vi_yank() {
    zvm_yank
    echo -n "${CUTBUFFER}" | clipboard
    zvm_exit_visual_mode
  }

  function zvm_vi_put_after() {
    local clip_content="$(clipboard_get)"
    [[ -n "$clip_content" ]] && CUTBUFFER="$clip_content"
    zvm_vicmd "put-after"
  }

  function zvm_vi_put_before() {
    local clip_content="$(clipboard_get)"
    [[ -n "$clip_content" ]] && CUTBUFFER="$clip_content"
    zvm_vicmd "put-before"
  }

  zvm_bindkey vicmd 'y' zvm_vi_yank
  zvm_bindkey vicmd 'p' zvm_vi_put_after
  zvm_bindkey vicmd 'P' zvm_vi_put_before
}
