;;; $DOOMDIR/lisp/format.el -*- lexical-binding: t; -*-
;; Formatting (apheleia) and linting (flycheck). Mirrors
;; ~/.config/nvim/lua/plugins/conform.lua and nvim-lint.lua.

;;
;;; Formatting

(after! apheleia
  ;; css/scss/html/json/yaml already default to prettier-* in apheleia's
  ;; built-in `apheleia-mode-alist'; lua/sh/go/rust already default to
  ;; stylua/shfmt/gofmt/rustfmt. Only the deltas from those defaults follow.

  ;; markdown isn't formatted by default (apheleia leaves it to the user) --
  ;; nvim does format it, just not on save (see +format-on-save-disabled-modes
  ;; below).
  (set-formatter! 'prettier-markdown :modes '(markdown-mode markdown-ts-mode))

  ;; prefer goimports over gofmt when it's installed (mason ships it).
  (when (executable-find "goimports")
    (set-formatter! 'goimports :modes '(go-mode go-ts-mode)))

  ;; Blade files (.blade.php) read from stdin, write to stdout.
  (set-formatter! 'blade-formatter '("blade-formatter" "--stdin"))

  (defun +format-php--resolve-bin (name)
    "Resolve php tool NAME: project vendor/bin/NAME first, else global NAME."
    (let* ((root (locate-dominating-file (or buffer-file-name default-directory)
                                          "composer.json"))
           (local (and root (expand-file-name (concat "vendor/bin/" name) root))))
      (or (and local (file-executable-p local) local)
          (executable-find name))))

  ;; Pint has no stdin mode -- format the temp file in place.
  (set-formatter! 'pint
    '((+format-php--resolve-bin "pint") inplace))
  ;; php-cs-fixer likewise only formats real files.
  (set-formatter! 'php-cs-fixer
    '((+format-php--resolve-bin "php-cs-fixer") "fix" inplace))

  ;; Base default for php-mode/php-ts-mode: fall back to intelephense's own
  ;; formatter (via Doom's `lsp' pseudo-formatter) when neither pint nor
  ;; php-cs-fixer is installed (composer is currently absent), instead of
  ;; erroring on every save.
  (set-formatter! 'lsp :modes '(php-mode php-ts-mode))

  (defun +format-php-formatter ()
    "Pick the php apheleia formatter for the current buffer.
Pint > php-cs-fixer > lsp (intelephense), in that order of availability."
    (cond ((+format-php--resolve-bin "pint") 'pint)
          ((+format-php--resolve-bin "php-cs-fixer") 'php-cs-fixer)
          (t 'lsp)))

  (defun +format-php-set-formatter-h ()
    (setq-local apheleia-formatter (+format-php-formatter)))
  (add-hook! '(php-mode-hook php-ts-mode-hook) #'+format-php-set-formatter-h)

  ;; .blade.php opens in web-mode (see lisp/lang-php.el), so it needs a
  ;; per-file override instead of a mode-alist entry -- otherwise every
  ;; web-mode buffer would be sent through blade-formatter.
  (defun +format-web-mode-set-formatter-h ()
    (setq-local apheleia-formatter
                (cond ((and buffer-file-name
                            (string-match-p "\\.blade\\.php\\'" buffer-file-name))
                       (if (executable-find "blade-formatter") 'blade-formatter 'lsp))
                      ((executable-find "prettier") nil) ; default web-mode -> prettier
                      (t 'lsp))))
  (add-hook! 'web-mode-hook #'+format-web-mode-set-formatter-h)

  ;; nvim's conform skips format-on-save for markdown and gitcommit.
  (dolist (mode '(markdown-mode markdown-ts-mode gfm-mode git-commit-mode text-mode))
    (add-to-list '+format-on-save-disabled-modes mode)))

;;
;;; Linting

(after! flycheck
  (when (executable-find "eslint_d")
    (setq flycheck-javascript-eslint-executable "eslint_d"))

  ;; nil = let a project phpcs.xml/phpcs.xml.dist decide; phpcs's own
  ;; default (PSR-12-ish) applies otherwise.
  (setq flycheck-phpcs-standard nil)

  (defun +format-flycheck-chain-lsp-checkers-h ()
    "Chain nvim-parity linters after lsp-mode's `lsp' flycheck checker.
lsp-mode makes `lsp' the buffer's exclusive checker, so the nvim linters
have to run as its next-checkers to run at all. `flycheck-add-next-checker'
removes any prior entry for the same pair before adding, so it's safe to
call repeatedly -- this hook fires every time lsp-mode (re)attaches."
    (when (and lsp-managed-mode (flycheck-valid-checker-p 'lsp))
      (when (executable-find "phpcs")
        (flycheck-add-next-checker 'lsp 'php-phpcs))
      (when (executable-find "eslint_d")
        (flycheck-add-next-checker 'lsp 'javascript-eslint))
      (when (executable-find "markdownlint")
        (flycheck-add-next-checker 'lsp 'markdown-markdownlint-cli))
      (when (executable-find "yamllint")
        (flycheck-add-next-checker 'lsp 'yaml-yamllint))
      (when (executable-find "shellcheck")
        (flycheck-add-next-checker 'lsp 'sh-shellcheck))))
  (add-hook 'lsp-managed-mode-hook #'+format-flycheck-chain-lsp-checkers-h))
