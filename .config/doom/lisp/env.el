;;; $DOOMDIR/lisp/env.el -*- lexical-binding: t; -*-

;; exec-path/PATH setup and project discovery. Must run at load time (not in
;; a hook) since lsp-mode probes `executable-find' early during startup.

(defun +env/prepend-to-path (dir)
  "Prepend DIR to both `exec-path' and the PATH env var, if it exists on disk.
No-op if DIR is missing. Idempotent: won't add DIR twice."
  (when (file-directory-p dir)
    (let* ((dir (directory-file-name (expand-file-name dir)))
           (path-list (split-string (getenv "PATH") path-separator t)))
      (unless (member dir exec-path)
        (push dir exec-path))
      (unless (member dir path-list)
        (setenv "PATH" (concat dir path-separator (getenv "PATH")))))))

(defun +env--mise-node-bin ()
  "Return the mise-managed node bin directory, or nil if none can be found.
Reads the pinned version from `node = \"...\"' in ~/.config/mise/config.toml
and uses ~/.local/share/mise/installs/node/<version>/bin if it exists.
Falls back to the newest installed node version otherwise. Ports
`mise_node_bin()' from nvim/lua/config/lsp/servers.lua."
  (let* ((installs-dir (expand-file-name "~/.local/share/mise/installs/node/"))
         (config-file (expand-file-name "~/.config/mise/config.toml"))
         (pinned-version
          (when (file-exists-p config-file)
            (with-temp-buffer
              (insert-file-contents config-file)
              (goto-char (point-min))
              (when (re-search-forward "^[ \t]*node[ \t]*=[ \t]*\"\\([^\"]+\\)\"" nil t)
                (match-string 1)))))
         (pinned-bin
          (when pinned-version
            (expand-file-name "bin" (expand-file-name pinned-version installs-dir)))))
    (cond
     ((and pinned-bin (file-directory-p pinned-bin)) pinned-bin)
     ((file-directory-p installs-dir)
      (let* ((version-dirs (seq-filter
                             (lambda (f) (and (file-directory-p f) (not (file-symlink-p f))))
                             (directory-files installs-dir t "^[0-9]")))
             (newest (car (sort version-dirs #'file-newer-than-file-p))))
        (when newest (expand-file-name "bin" newest)))))))

;; Precedence order: first entry ends up first on PATH, so prepend in reverse.
(+env/prepend-to-path "~/go/bin")
(let ((node-bin (+env--mise-node-bin)))
  (when node-bin (+env/prepend-to-path node-bin)))
(+env/prepend-to-path "~/.composer/vendor/bin")
(+env/prepend-to-path "~/.config/composer/vendor/bin")
;; All LSP servers/formatters/linters live here.
(+env/prepend-to-path "~/.local/share/nvim/mason/bin")
(+env/prepend-to-path "~/.local/bin")


;;
;;; Projects

(after! projectile
  (setq projectile-project-search-path '("~/Works")
        projectile-indexing-method 'alien)
  ;; "composer.json" is already added by Doom's :lang php module.
  (dolist (marker '("artisan" "wp-config.php" "package.json"
                     "docker-compose.yml" "compose.yaml"))
    (add-to-list 'projectile-project-root-files marker)))
