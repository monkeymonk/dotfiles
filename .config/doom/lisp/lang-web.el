;;; $DOOMDIR/lisp/lang-web.el -*- lexical-binding: t; -*-

;;
;;; node_modules

;; Prefer project-local `node_modules/.bin' binaries (prettier, eslint,
;; tsserver) over anything on the global PATH.
(add-hook! '(js-mode-hook js-ts-mode-hook
             typescript-mode-hook typescript-ts-mode-hook tsx-ts-mode-hook
             web-mode-hook
             css-mode-hook css-ts-mode-hook scss-mode-hook
             json-mode-hook json-ts-mode-hook)
           #'add-node-modules-path)

;;
;;; web-mode

(after! web-mode
  (setq web-mode-markup-indent-offset 2
        web-mode-css-indent-offset 2
        web-mode-code-indent-offset 2
        ;; Fights with typing quotes in JSX/Blade attributes; smartparens
        ;; (`:config +smartparens') already handles auto-pairing.
        web-mode-enable-auto-quoting nil))

;;
;;; dotenv

;; The package's own autoloads already map `.env' and `.env.example'; extend
;; to Laravel-style `.env.local', `.env.testing', etc.
(use-package! dotenv-mode
  :mode "\\.env\\'"
  :mode "\\.env\\..*\\'")

;;
;;; Markdown

;; `markdown-fontify-code-blocks-natively' is already t and `markdown-command'
;; already dispatches through pandoc (among others) via `+markdown-compile' --
;; see lang/markdown/config.el. Overriding `markdown-command' directly would
;; lose that fallback chain, so it's left alone.
;;
;; `markdown-mode' derives from `text-mode', so it already inherits
;; `+word-wrap-mode' from editor/word-wrap's `text-mode-hook' entry.
;; `markdown-ts-mode' (used when the `+tree-sitter' flag remaps to it)
;; derives from `fundamental-mode' instead and does NOT inherit that hook --
;; wire both explicitly so wrapping works regardless of which mode is active.
;;
;; `+word-wrap-mode' also turns on `visual-line-mode', so no separate
;; `visual-line-mode' hook is needed here.
(add-hook! '(markdown-mode-hook markdown-ts-mode-hook) #'+word-wrap-mode)

(after! markdown-mode
  ;; Hide `**', `_', link syntax etc. `markdown-toggle-markup-hiding' toggles
  ;; it per buffer. NOTE: `markdown-hide-markup' is declared with
  ;; `make-variable-buffer-local' (markdown-mode.el:1922), so a plain `setq'
  ;; here would only touch whatever buffer happened to be current at load
  ;; time -- it must be `setq-default'.
  ;;
  ;; This only works in `markdown-mode'. `markdown-ts-mode' derives from
  ;; `fundamental-mode' and does its own tree-sitter fontification, so it
  ;; ignores this variable entirely -- which is why the markdown module is
  ;; enabled WITHOUT `+tree-sitter' in init.el.
  (setq-default markdown-hide-markup t))

;; Rendered view in normal/visual state; raw syntax on the line being edited in
;; insert state. `markdown-hide-markup' hides markup on every line including
;; the one point is on, which is fine for reading but not for editing.
;;
;; Note `reveal-mode' does NOT work here: markdown-mode hides markup with the
;; `invisible' TEXT PROPERTY, and reveal-mode only un-hides overlays. An
;; overlay with `invisible nil' doesn't shadow it either. So the current line
;; is revealed by removing the property, and restored by refontifying.
(defvar-local +markdown-appear--line nil
  "Cons of (BEG . END) for the line currently revealed, or nil.")

(defun +markdown-appear--rehide ()
  "Restore hidden markup on the previously revealed line."
  (when +markdown-appear--line
    (font-lock-flush (car +markdown-appear--line) (cdr +markdown-appear--line))
    (setq +markdown-appear--line nil)))

(defun +markdown-appear--reveal-line ()
  "Reveal hidden markup on the line at point, re-hiding the previous one."
  (let ((beg (line-beginning-position))
        (end (line-end-position)))
    (unless (equal (cons beg end) +markdown-appear--line)
      (+markdown-appear--rehide)
      (setq +markdown-appear--line (cons beg end))
      ;; `with-silent-modifications' keeps this out of the undo log and leaves
      ;; `buffer-modified-p' alone -- revealing markup is not an edit.
      (with-silent-modifications
        (remove-text-properties beg end '(invisible nil))))))

(defun +markdown-appear--enter-insert ()
  (add-hook 'post-command-hook #'+markdown-appear--reveal-line nil t)
  (+markdown-appear--reveal-line))

(defun +markdown-appear--exit-insert ()
  (remove-hook 'post-command-hook #'+markdown-appear--reveal-line t)
  (+markdown-appear--rehide))

(define-minor-mode +markdown-appear-mode
  "Show raw markup on the edited line in insert state, hide it elsewhere."
  :init-value nil
  (if +markdown-appear-mode
      (progn
        (add-hook 'evil-insert-state-entry-hook #'+markdown-appear--enter-insert nil t)
        (add-hook 'evil-insert-state-exit-hook #'+markdown-appear--exit-insert nil t))
    (remove-hook 'evil-insert-state-entry-hook #'+markdown-appear--enter-insert t)
    (remove-hook 'evil-insert-state-exit-hook #'+markdown-appear--exit-insert t)
    (+markdown-appear--exit-insert)))

(add-hook 'markdown-mode-hook #'+markdown-appear-mode)

;; Centered, fixed-measure prose column. `visual-fill-column' is already
;; installed by `:editor word-wrap' -- no `package!' declaration needed.
;; That module only enables `visual-fill-column-mode' when
;; `+word-wrap-fill-style' is `auto' or `soft'; it defaults to nil, so the
;; hook below is what actually turns it on.
(use-package! visual-fill-column
  :hook (markdown-mode . visual-fill-column-mode)
  :hook (markdown-ts-mode . visual-fill-column-mode)
  :config
  (setq-default visual-fill-column-width 85
                visual-fill-column-center-text t))

;;
;;; Tree-sitter

;; Major-mode remapping (php-ts-mode, tsx-ts-mode, css-ts-mode, json-ts-mode,
;; markdown-ts-mode, ...) is handled by each lang module's `set-tree-sitter!'
;; call under the `+tree-sitter' flag. Nothing to hand-roll here.
