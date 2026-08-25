;;; $DOOMDIR/lisp/ui.el -*- lexical-binding: t; -*-

;; Font, theme, and editor options. Line numbers, scroll margins, split
;; direction, and indent width mirror nvim/lua/config/options.lua.

;; "JetBrainsMono Nerd Font" is the installed family name; plain "JetBrains
;; Mono" is not installed and fontconfig falls back to Noto Sans Mono, which
;; also loses the nerd-font glyphs the modeline/dashboard/dirvish draw.
(setq doom-font (font-spec :family "JetBrainsMono Nerd Font" :size 14)
      ;; Used by `variable-pitch-mode' -- org, markdown headings, some UI.
      doom-variable-pitch-font (font-spec :family "Inter" :size 15))
(setq catppuccin-flavor 'mocha)
(setq doom-theme 'catppuccin)

(setq display-line-numbers-type 'relative)

;; nvim `scrolloff' / `sidescrolloff'.
(setq scroll-margin 4
      hscroll-margin 8)

(after! evil
  ;; nvim `splitbelow' / `splitright'.
  (setq evil-split-window-below t
        evil-vsplit-window-right t
        evil-want-fine-undo t))

;; nvim `timeoutlen' 300.
(after! which-key
  (setq which-key-idle-delay 0.3))

;; Default 2-space indent; lang-php.el overrides to 4 for PHP (PSR-12).
(setq standard-indent 2)
(setq-default tab-width 2
              indent-tabs-mode nil)
