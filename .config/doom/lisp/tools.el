;;; $DOOMDIR/lisp/tools.el -*- lexical-binding: t; -*-

;; Docker, dape, claude-code-ide, wakatime, tmux, REST client.

;;
;;; Docker

;; `docker-compose-mode' autoloads its own `docker-compose*.yml' entry, but
;; :lang yaml also claims `.yml'/`.yaml'. `add-to-list' prepends, and this
;; runs after all package autoloads have loaded, so these win regardless of
;; module load order. Also cover the plain Compose v2 `compose.yaml' name,
;; which the package doesn't. docker-compose-mode derives from yaml-mode, so
;; yaml indentation/lsp behaviour is unaffected.
(add-to-list 'auto-mode-alist '("docker-compose[^/]*\\.ya?ml\\'" . docker-compose-mode))
(add-to-list 'auto-mode-alist '("compose[^/]*\\.ya?ml\\'" . docker-compose-mode))

;; Emacs 30 ships `tramp-container', which registers the `docker' tramp
;; method (`/docker:container:/path') via `;;;###tramp-autoload' cookies —
;; it activates on first use without an explicit `require'. Nothing to add.

;; The `docker' transient (all containers/images/volumes/compose commands)
;; is already bound at "SPC o D" by Doom's default bindings module
;; (config/default/+evil-bindings.el); "SPC o d" is taken by
;; `+debugger/start'. No further docker keybinding needed.

;;
;;; dape

(defvar +debugger-php-docker-root "/var/www/html"
  "Container-side project root for the PHP/Xdebug docker dape config.
Override in a project's `.dir-locals.el' if the container uses a
different path.")

(after! dape
  ;; PHP/Xdebug: dape already ships an `xdebug' config (plain "listen for
  ;; Xdebug", port 9003, vscode-php-debug via node) — that covers the local
  ;; case. Add a docker variant with `pathMappings', reusing the same
  ;; adapter command/ensure logic so the adapter path isn't duplicated.
  ;; Mirrors nvim/lua/util/dap.lua's "PHP: Docker Xdebug" config.
  (let ((xdebug (alist-get 'xdebug dape-configs)))
    (add-to-list
     'dape-configs
     `(xdebug-docker
       modes (php-mode php-ts-mode)
       ensure ,(plist-get xdebug 'ensure)
       command ,(plist-get xdebug 'command)
       command-args ,(plist-get xdebug 'command-args)
       :type "php"
       :request "launch"
       :port 9003
       :pathMappings ,(lambda ()
                        (let ((h (make-hash-table :test 'equal)))
                          (puthash +debugger-php-docker-root
                                   (or (doom-project-root) default-directory)
                                   h)
                          h)))))

  ;; Node/Chrome: dape's js-debug adapter already ships `js-debug-node',
  ;; `js-debug-ts-node', `js-debug-tsx', `js-debug-node-attach' and
  ;; `js-debug-chrome' — full launch/attach parity with
  ;; nvim/lua/util/dap.lua's node2/chrome configs. Nothing to add.
  )

;; "SPC d" is already a full debugger leader group (config/default), bound
;; to dape-continue/-next/-step-in/-step-out/etc. F10 and F11 are vanilla
;; Emacs globals (`menu-bar-open', `toggle-frame-fullscreen') — left alone.
;; F5 and S-F11 are free; bind those for nvim muscle-memory parity.
(map! :desc "Dape continue"  "<f5>" #'dape-continue
      :desc "Dape step out"  "<S-f11>" #'dape-step-out)

;;
;;; claude-code-ide

(use-package! claude-code-ide
  :defer t
  :init
  ;; `eat' is installed; the user has no vterm.
  (setq claude-code-ide-terminal-backend 'eat))

;; Mirrors nvim README's `<leader>a' group. Only commands that exist in the
;; installed package are bound: no model-select, buffer-add, or diff
;; accept/deny commands ship in this package (diffs use plain ediff keys).
(map! :leader
      (:prefix-map ("a" . "claude")
       :desc "Toggle Claude"  "c" #'claude-code-ide-toggle
       :desc "Focus Claude"   "f" #'claude-code-ide-switch-to-buffer
       :desc "Resume"         "r" #'claude-code-ide-resume
       :desc "Continue"       "C" #'claude-code-ide-continue
       :desc "Send selection" :v "s" #'claude-code-ide-insert-at-mentioned))

;;
;;; wakatime

(defvar +wakatime-cli-path
  (or (executable-find "wakatime-cli")
      (let ((cli (expand-file-name "~/.wakatime/wakatime-cli")))
        (and (file-exists-p cli) cli)))
  "Resolved wakatime CLI path, or nil if none was found.")

(use-package! wakatime-mode
  :when (and +wakatime-cli-path (file-exists-p "~/.wakatime.cfg"))
  :hook (doom-first-file . global-wakatime-mode)
  :init
  (setq wakatime-cli-path +wakatime-cli-path))

;;
;;; REST client

;; `:lang rest' already maps `.http' to `restclient-mode'; add `.rest'.
(add-to-list 'auto-mode-alist '("\\.rest\\'" . restclient-mode))

;;
;;; tmux

;; `:tools tmux' is autoload-only (+tmux/run, +tmux/send-region,
;; +tmux/cd-to-project, ...) with no existing Doom leader bindings and no
;; nvim-side convention to mirror (nvim's only tmux integration is pane
;; navigation via vim-tmux-navigator, a different feature). Left unbound —
;; invoke via `M-x +tmux/...' or bind project-locally if needed.
