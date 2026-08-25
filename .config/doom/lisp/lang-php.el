;;; $DOOMDIR/lisp/lang-php.el -*- lexical-binding: t; -*-

;; The `:lang (php +lsp +tree-sitter)' module (lang/php/config.el) already
;; provides: php-mode/php-ts-mode setup, the psysh REPL (`+php/open-repl'),
;; phpunit bindings under localleader "t", composer under "c", php-refactor
;; under "r", docsets, ligatures, `<?php' smartparens pairs, and the project
;; modes `+php-laravel-mode', `+php-composer-mode',
;; `+phpunit-docker-compose-mode' (plus `+php-default-docker-container',
;; `+php-default-docker-compose', `+php-run-tests-in-docker'). Nothing here
;; reimplements any of that.

;; Forward declaration so `+php/tinker' can dynamically bind this without
;; requiring `psysh' eagerly (it's autoloaded on first use by the module).
(defvar psysh-comint-buffer-process)

;;
;;; Indentation

;; php-mode defaults to the "pear" c-style (`c-basic-offset' 4, `tab-width'
;; 4) and php-ts-mode defaults to `php-ts-mode-indent-style' `psr2' with
;; `php-ts-mode-indent-offset' 4 -- both already match PSR-12, nothing to
;; override. Blade/web-mode indentation (2 spaces) is set in lang-web.el.

;;
;;; Blade

(after! web-mode
  (add-to-list 'web-mode-engines-alist '("blade" . "\\.blade\\.php\\'")))

;;
;;; WordPress project mode

(def-project-mode! +php-wordpress-mode
  :modes '(php-mode php-ts-mode web-mode)
  :files ("wp-config.php"))

;;
;;; Laravel: artisan runner

(defvar +php-artisan-commands-cache (make-hash-table :test 'equal)
  "Cache of `php artisan list --raw' output, keyed by project root.")

(defun +php--artisan-root ()
  "Return the project root if it contains an `artisan' file, else nil."
  (let ((root (doom-project-root)))
    (and root (file-exists-p (expand-file-name "artisan" root)) root)))

(defun +php--artisan-command-list (root)
  "Return the cached list of `artisan' command names for ROOT, if cheaply available."
  (or (gethash root +php-artisan-commands-cache)
      (and (executable-find "php")
           (ignore-errors
             (let ((default-directory root))
               (with-temp-buffer
                 (when (zerop (call-process "php" nil t nil "artisan" "list" "--raw"))
                   (let ((cmds (seq-filter
                                (lambda (s) (not (string-empty-p s)))
                                (mapcar (lambda (line) (car (split-string line "[ \t]" t)))
                                        (split-string (buffer-string) "\n" t)))))
                     (when cmds
                       (puthash root cmds +php-artisan-commands-cache))))))))))

(defun +php/artisan (command)
  "Run `php artisan COMMAND' from the project root in a compilation buffer.

If `+php-run-tests-in-docker' is non-nil, run it through
`docker compose exec +php-default-docker-container' instead."
  (interactive
   (let ((root (+php--artisan-root)))
     (unless root
       (user-error "No `artisan' file found at the project root"))
     (list (if-let* ((candidates (+php--artisan-command-list root)))
               (completing-read "Artisan command: " candidates)
             (read-string "Artisan command: ")))))
  (let* ((root (or (+php--artisan-root)
                    (user-error "No `artisan' file found at the project root")))
         (default-directory root)
         (args (split-string command " " t))
         (cmd (if +php-run-tests-in-docker
                  (append (list "docker" "compose" "exec" +php-default-docker-container
                                "php" "artisan")
                          args)
                (append (list "php" "artisan") args))))
    (compile (mapconcat #'shell-quote-argument cmd " "))))

;;
;;; Laravel: tinker

(defun +php/tinker ()
  "Open a psysh REPL, running `php artisan tinker' in Laravel projects.

Falls back to a plain psysh REPL outside of Laravel projects. Reuses the
module's `+php/open-repl' handler rather than reimplementing a REPL."
  (interactive)
  (if-let* ((root (+php--artisan-root)))
      ;; `psysh-comint-buffer-process' is applied to `make-comint', whose third
      ;; argument is STARTFILE -- hence the nil before the process args.
      (let ((default-directory root)
            (psysh-comint-buffer-process
             (list "artisan-tinker" "php" nil "artisan" "tinker")))
        (+php/open-repl))
    (+php/open-repl)))

;;
;;; Laravel: jump to Blade view/component

;; Port of nvim/lua/util/blade_nav.lua. Detects the view/component reference
;; under point via regex (rather than the original's manual quote-scanning,
;; which doesn't translate cleanly to Elisp) and resolves it the same way.

(defun +php--blade-find-views-root (file)
  "Walk up from FILE looking for a `resources/views' directory."
  (let ((dir (file-name-directory (expand-file-name file))))
    (catch 'found
      (while (and dir (not (equal dir "/")))
        (let ((candidate (expand-file-name "resources/views" dir)))
          (when (file-directory-p candidate)
            (throw 'found candidate)))
        (setq dir (file-name-directory (directory-file-name dir))))
      nil)))

(defun +php--blade-view-token ()
  "Return (TOKEN . KIND) for the Blade view/component reference at point, or nil.

KIND is `view' for `view(...)'/`@include(...)'/`@extends(...)'/
`@component(...)'/`@each(...)' (and the includeIf/includeWhen/includeFirst
variants), or `component' for an `<x-foo.bar>' tag."
  (let ((line-start (line-beginning-position))
        (line-end (line-end-position))
        (pt (point)))
    (or
     (save-excursion
       (goto-char line-start)
       (let (found)
         (while (and (not found)
                     (re-search-forward
                      "\\(?:@\\(?:include\\(?:If\\|When\\|First\\)?\\|extends\\|component\\|each\\)\\|\\_<view\\)[ \t]*([ \t]*['\"]\\([^'\"]*\\)['\"]"
                      line-end t))
           (when (and (<= (match-beginning 1) pt) (<= pt (match-end 1)))
             (setq found (match-string-no-properties 1))))
         (when found (cons found 'view))))
     (save-excursion
       (goto-char line-start)
       (let (found)
         (while (and (not found)
                     (re-search-forward "<x[-:][A-Za-z0-9._:-]+" line-end t))
           (when (and (<= (match-beginning 0) pt) (<= pt (match-end 0)))
             (setq found (substring (match-string-no-properties 0) 1))))
         (when found (cons found 'component)))))))

(defun +php--blade-component-path (token)
  "Convert Blade component TOKEN (e.g. \"x-foo.bar\") to \"foo/bar\"."
  (let* ((name (replace-regexp-in-string "\\`x[-:]" "" token))
         (name (replace-regexp-in-string "::" "/" name))
         (name (replace-regexp-in-string "\\." "/" name)))
    name))

(defun +php--blade-pascalize (path)
  "Convert slash/kebab-case PATH to Laravel's StudlyCase class path.

E.g. \"inputs/text-field\" -> \"Inputs/TextField\"."
  (mapconcat
   (lambda (segment) (mapconcat #'capitalize (split-string segment "-" t) ""))
   (split-string path "/" t)
   "/"))

(defun +php--blade-resolve (views-root project-root token kind)
  "Resolve TOKEN of KIND to a file path under VIEWS-ROOT/PROJECT-ROOT, or nil."
  (pcase kind
    ('view
     (let* ((rel (replace-regexp-in-string "\\." "/" token))
            (blade (expand-file-name (concat rel ".blade.php") views-root))
            (php (expand-file-name (concat rel ".php") views-root)))
       (cond ((file-exists-p blade) blade)
             ((file-exists-p php) php)
             (t (car (file-expand-wildcards
                      (expand-file-name (concat rel "*.blade.php") views-root)))))))
    ('component
     (let* ((path (+php--blade-component-path token))
            (blade (expand-file-name (concat "components/" path ".blade.php") views-root))
            (class (and project-root
                        (expand-file-name
                         (concat "app/View/Components/" (+php--blade-pascalize path) ".php")
                         project-root))))
       (cond ((file-exists-p blade) blade)
             ((car (file-expand-wildcards
                    (expand-file-name (concat "components/" path "*.blade.php") views-root))))
             ((and class (file-exists-p class)) class))))))

(defun +php/find-blade-view ()
  "Jump to the Blade view or component referenced at point.

Handles `view(\"foo.bar\")', `@include(\"foo.bar\")', `@extends(...)',
`@component(...)', `@each(...)' and `<x-foo.bar>' component tags."
  (interactive)
  (let ((file (or (buffer-file-name) (user-error "Buffer has no file on disk"))))
    (let ((views-root (or (+php--blade-find-views-root file)
                           (user-error "Couldn't locate resources/views")))
          (project-root (doom-project-root)))
      (pcase-let ((`(,token . ,kind)
                   (or (+php--blade-view-token)
                       (user-error "No Blade view or component at point"))))
        (let ((target (+php--blade-resolve views-root project-root token kind)))
          (unless target
            (user-error "View not found for `%s'" token))
          (find-file target))))))

(map! :after php-mode
      :localleader :map php-mode-map
      :desc "Artisan command"  "a" #'+php/artisan
      :desc "Tinker REPL"      "T" #'+php/tinker
      :desc "Goto Blade view"  "v" #'+php/find-blade-view)

(map! :after php-ts-mode
      :localleader :map php-ts-mode-map
      :desc "Artisan command"  "a" #'+php/artisan
      :desc "Tinker REPL"      "T" #'+php/tinker
      :desc "Goto Blade view"  "v" #'+php/find-blade-view)

(map! :after web-mode
      :localleader :map web-mode-map
      :desc "Goto Blade view" "v" #'+php/find-blade-view)

;;
;;; PHP stubs (WordPress/WooCommerce/ACF Pro for intelephense)

;; Port of nvim/lua/config/php_stubs.lua. Never run at startup; invoke
;; `+php/install-stubs' manually when working on a WordPress project.

(defvar +php-stubs-directory (expand-file-name "~/.local/share/php-stubs")
  "Composer project directory holding PHP stub packages for intelephense.")

(defvar +php-stub-packages
  '("php-stubs/wordpress-stubs:^6.0"
    "php-stubs/woocommerce-stubs:^6.0"
    "php-stubs/acf-pro-stubs:^6.0")
  "Composer packages providing PHP stubs for intelephense.")

(defun +php--stub-vendor-dir ()
  (expand-file-name "vendor/php-stubs" +php-stubs-directory))

(defun +php--stub-installed-p (pkg)
  "Return non-nil if composer package PKG (\"vendor/name[:version]\") is vendored."
  (let ((name (file-name-nondirectory (car (split-string pkg ":")))))
    (file-directory-p (expand-file-name name (+php--stub-vendor-dir)))))

(defun +php--stub-run (args on-success)
  "Run `composer ARGS' asynchronously in `+php-stubs-directory'.

Calls ON-SUCCESS with no arguments if the process exits with status 0;
otherwise reports the failure via `message'."
  (let* ((buf (generate-new-buffer " *php-stubs*"))
         (default-directory +php-stubs-directory))
    (make-process
     :name "php-stubs-composer"
     :buffer buf
     :command (cons (executable-find "composer") args)
     :noquery t
     :sentinel
     (lambda (proc _event)
       (unless (process-live-p proc)
         (if (zerop (process-exit-status proc))
             (progn (kill-buffer buf) (funcall on-success))
           (message "PHP stubs: `composer %s' failed:\n%s"
                    (mapconcat #'identity args " ")
                    (with-current-buffer buf (string-trim (buffer-string))))
           (kill-buffer buf)))))))

(defun +php--stub-refresh-intelephense ()
  "Re-apply stub include paths and restart any active intelephense workspace."
  (message "PHP stubs: install complete.")
  (when (fboundp '+lsp-php-stub-paths)
    (setq lsp-intelephense-paths-include (funcall '+lsp-php-stub-paths)))
  (when (require 'lsp-mode nil t)
    (dolist (ws (lsp--session-workspaces (lsp-session)))
      (when (eq (lsp--workspace-server-id ws) 'iph)
        (lsp-workspace-restart ws)))))

(defun +php--stub-install-remaining (pkgs)
  "Require each not-yet-installed package in PKGS, one at a time."
  (if (null pkgs)
      (+php--stub-refresh-intelephense)
    (let ((pkg (car pkgs)))
      (if (+php--stub-installed-p pkg)
          (+php--stub-install-remaining (cdr pkgs))
        (message "PHP stubs: installing %s..." pkg)
        (+php--stub-run (list "require" "--dev" pkg)
                         (lambda () (+php--stub-install-remaining (cdr pkgs))))))))

(defun +php/install-stubs ()
  "Install WordPress/WooCommerce/ACF Pro stubs for intelephense via Composer.

No-ops with a clear message if composer isn't on `exec-path'. Never call this
automatically; it's a manual, per-project opt-in."
  (interactive)
  (if (not (executable-find "composer"))
      (message "PHP stubs: composer not found on PATH -- install it (https://getcomposer.org) to use WordPress/WooCommerce/ACF stubs")
    (make-directory +php-stubs-directory t)
    (if (file-exists-p (expand-file-name "composer.json" +php-stubs-directory))
        (+php--stub-install-remaining +php-stub-packages)
      (message "PHP stubs: initializing composer project...")
      (+php--stub-run (list "init" "-n" "--name=stubs/php")
                       (lambda () (+php--stub-install-remaining +php-stub-packages))))))

(defun +php/stubs-status ()
  "Report which PHP stubs are installed under `+php-stubs-directory'."
  (interactive)
  (let ((installed (and (file-directory-p (+php--stub-vendor-dir))
                         (sort (directory-files (+php--stub-vendor-dir) nil "\\`[^.]")
                               #'string<))))
    (if installed
        (message "PHP stubs installed in %s: %s"
                 +php-stubs-directory (mapconcat #'identity installed ", "))
      (message "PHP stubs: none installed (%s)" +php-stubs-directory))))
