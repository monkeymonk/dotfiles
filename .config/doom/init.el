;;; $DOOMDIR/init.el -*- lexical-binding: t; -*-

;; This file controls what Doom modules are enabled and what order they load
;; in. Remember to run 'doom sync' after modifying it!

;; NOTE: Press 'SPC h d h' (or 'C-h d h' for non-vim users) to access Doom's
;;   documentation. There you'll find a link to Doom's Module Index where all of
;;   our modules are listed, including what flags they support.

;; NOTE: Move your cursor over a module's name (or its flags) and press 'K' (or
;;   'C-c c k' for non-vim users) to view its documentation. This works on flags
;;   as well (those symbols that start with a plus).
;;
;;   Alternatively, press 'gd' (or 'C-c c d') on a module to browse its
;;   directory (for easy access to its source code).

(doom! :input

       :completion
       (corfu +orderless +icons +dabbrev)
       (vertico +icons +childframe)

       :ui
       doom
       dashboard
       (emoji +unicode)
       hl-todo
       indent-guides
       (ligatures +extra)
       minimap
       modeline
       nav-flash
       ophints
       (popup +defaults)
       unicode
       (vc-gutter +pretty)
       vi-tilde-fringe
       window-select
       workspaces

       :editor
       (evil +everywhere)
       file-templates
       fold
       (format +onsave +lsp)
       snippets
       (whitespace +guess +trim)
       word-wrap

       :emacs
       (dired +dirvish +icons)
       electric
       (ibuffer +icons)
       tramp
       (undo +tree)
       vc

       :term
       ghostel

       :checkers
       (syntax +childframe +icons)
       (spell +flyspell)

       :tools
       debugger
       direnv
       (docker +lsp +tree-sitter)
       editorconfig
       (eval +overlay)
       (lookup +docsets)
       llm
       (lsp +peek)
       (magit +forge)
       make
       tmux
       tree-sitter

       :os
       (:if (featurep :system 'macos) macos)
       tty

       :lang
       common-lisp
       data
       emacs-lisp
       (gdscript +lsp +tree-sitter)
       (go +lsp +tree-sitter)
       (graphql +lsp +tree-sitter)
       graphviz
       (javascript +lsp +tree-sitter)
       (json +lsp +tree-sitter)
       latex
       (lua +lsp +tree-sitter)
       (markdown +lsp +grip)
       org
       (php +lsp +tree-sitter)
       (python +lsp +pyright +tree-sitter +uv)
       (rest +jq)
       (rust +lsp +tree-sitter)
       (sh +lsp)
       (web +lsp +tree-sitter)
       (yaml +lsp +tree-sitter)
       zig

       :config
       (default +bindings +smartparens))
