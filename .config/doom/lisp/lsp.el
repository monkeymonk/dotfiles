;;; $DOOMDIR/lisp/lsp.el -*- lexical-binding: t; -*-

;; lsp-mode tuning and every language-server client, mirroring
;; nvim/lua/config/lsp/servers.lua. All server binaries live under mason
;; (see lisp/env.el for the exec-path wiring); this file only adjusts how
;; lsp-mode talks to them.
;;
;; Verified against the installed lsp-mode clients: ts_ls, cssls, html,
;; jsonls, yamlls, bashls, gopls, rust_analyzer, pyright, lua_ls, emmet_ls
;; and dockerls all resolve their mason binary by name via `exec-path' with
;; no config needed (typescript-language-server, vscode-{css,html,json}-
;; language-server, yaml-language-server, bash-language-server, gopls,
;; rust-analyzer, pyright-langserver, lua-language-server, emmet-ls,
;; docker-langserver -- every name matches its mason bin symlink exactly).

(after! lsp-mode
  (setq lsp-idle-delay 0.5
        lsp-enable-file-watchers t
        lsp-file-watch-threshold 4000
        lsp-auto-execute-action nil
        ;; corfu owns completion; Doom wires the capf backend.
        lsp-completion-provider :none
        ;; lsp-eslint ships vscode-eslint, which isn't installed here (only
        ;; eslint_d, a CLI, not an LSP server) -- never let it auto-download
        ;; one. flycheck (format.el) drives ESLint diagnostics via eslint_d.
        lsp-eslint-enable nil)

  ;; Laravel/WordPress/JS build output that doesn't need watching.
  (dolist (re '("[/\\\\]vendor\\'"
                "[/\\\\]node_modules\\'"
                "[/\\\\]storage\\'"
                "[/\\\\]bootstrap[/\\\\]cache\\'"
                "[/\\\\]public[/\\\\]build\\'"
                "[/\\\\]public[/\\\\]hot\\'"
                "[/\\\\]dist\\'"
                "[/\\\\]\\.next\\'"
                "[/\\\\]wp-content[/\\\\]uploads\\'"
                "[/\\\\]wp-content[/\\\\]cache\\'"))
    (add-to-list 'lsp-file-watch-ignored-directories re))

  ;; `.blade.php' buffers open in web-mode; force intelephense's language id
  ;; so it still attaches to them.
  (add-to-list 'lsp-language-id-configuration '("\\.blade\\.php\\'" . "php"))

  ;; docker-compose: lsp-mode ships no client for it. yamlls (priority 0)
  ;; already handles plain YAML, so only outrank it on compose filenames --
  ;; regular *.yml/*.yaml buffers are untouched and still go to yamlls.
  (when (executable-find "docker-compose-langserver")
    (lsp-register-client
     (make-lsp-client
      :new-connection (lsp-stdio-connection '("docker-compose-langserver" "--stdio"))
      :activation-fn (lambda (filename _mode)
                       (and filename
                            (string-match-p "\\(?:^\\|[/\\\\]\\)\\(?:docker-\\)?compose[^/\\\\]*\\.ya?ml\\'"
                                            filename)))
      :priority 1
      :add-on? nil
      :server-id 'docker-compose-ls))))


;;
;;; lsp-ui

(after! lsp-ui
  (setq lsp-ui-sideline-enable nil
        lsp-ui-doc-enable nil))


;;
;;; intelephense (PHP)

(defun +lsp-php-stub-paths ()
  "Composer php-stubs package dirs for intelephense's includePaths.
Reads `~/.local/share/php-stubs/vendor/php-stubs/*', populated by
`+php/install-stubs' (lang-php.el). Returns an empty vector when that
directory is absent -- composer stub packages are optional and composer is
not currently installed."
  (let ((stubs-dir (expand-file-name "~/.local/share/php-stubs/vendor/php-stubs/")))
    (if (file-directory-p stubs-dir)
        (vconcat (seq-filter #'file-directory-p
                              (directory-files stubs-dir t "\\`[^.]")))
      [])))

(after! lsp-php
  (setq lsp-intelephense-files-associations ["*.php" "*.blade.php"]
        lsp-intelephense-files-max-size 5000000
        ;; Per-project roots only; multi-root causes cross-project symbol
        ;; bleed between the sibling projects under ~/Works.
        lsp-intelephense-multi-root nil
        lsp-intelephense-paths-include (+lsp-php-stub-paths))
  ;; intelephense bundles a "wordpress" stub but doesn't include it by
  ;; default; woocommerce/acf come from the composer stubs above instead,
  ;; since intelephense ships neither.
  (unless (seq-contains-p lsp-intelephense-stubs "wordpress" #'string=)
    (setq lsp-intelephense-stubs (vconcat lsp-intelephense-stubs ["wordpress"]))))


;;
;;; Tailwind CSS

(after! lsp-tailwindcss
  ;; `lsp-tailwindcss-server-path' must be a JS entry script (it's launched
  ;; as `node <path> --stdio'), not the mason shell shim. Fall back to
  ;; lsp-mode's managed install when the mason layout doesn't match.
  (let ((server (expand-file-name
                 "~/.local/share/nvim/mason/packages/tailwindcss-language-server/node_modules/@tailwindcss/language-server/bin/tailwindcss-language-server")))
    (when (file-exists-p server)
      (setq lsp-tailwindcss-server-path server)))
  (dolist (mode '(php-mode php-ts-mode scss-mode js-mode js-ts-mode typescript-ts-mode))
    (add-to-list 'lsp-tailwindcss-major-modes mode)))
