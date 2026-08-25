;;; $DOOMDIR/packages.el -*- lexical-binding: t; no-byte-compile: t -*-
(package! catppuccin-theme)

;;; Web/JS
(package! add-node-modules-path)
(package! dotenv-mode)
(package! docker-compose-mode)

;;; Terminal + AI
(package! eat)
(package! claude-code-ide
  :recipe (:host github :repo "manzaltu/claude-code-ide.el"))

;;; Tracking
(package! wakatime-mode)
