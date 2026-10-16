;;; format-all.el --- Format-all package configuration -*- lexical-binding: t; -*-

(defun format/register-mode (language mode)
  "Register MODE as LANGUAGE in language-id's mode table."
  (if-let ((definition (assoc language language-id--definitions)))
      (unless (memq mode (cdr definition))
        (setcdr definition (cons mode (cdr definition))))
    (push (list language mode) language-id--definitions)))

(defun format/formatter-available-p (formatter)
  "Return non-nil when FORMATTER can run in the current buffer."
  (let* ((normalized (format-all--normalize-formatter formatter))
         (name (car normalized)))
    (and (gethash name format-all--format-table)
         (condition-case nil
             (progn
               (format-all--command-args normalized)
               t)
           (format-all-executable-not-found nil)))))

(defun format/enable-on-save ()
  "Enable format-on-save when this buffer has an available formatter."
  (require 'format-all)
  (when-let* ((language (format-all--language-id-buffer))
              (chain (format-all--get-chain language))
              ((cl-every #'format/formatter-available-p chain)))
    (format-all-mode 1)))

(defun format/cancel-pending-setup ()
  "Cancel lazy setup, including when the user toggles `format-all-mode'."
  (remove-hook 'before-save-hook #'format/initialize-on-first-save t))

(defun format/initialize-on-first-save ()
  "Load the formatter on first save and format that save exactly once."
  (format/cancel-pending-setup)
  (unless (my-large-buffer-p)
    (format/enable-on-save)
    (when (bound-and-true-p format-all-mode)
      (format-all--buffer-from-hook))))

(defun format/prepare-on-save ()
  "Defer formatter loading and executable lookup until the first save."
  (unless (my-large-buffer-p)
    (if (format/use-lsp-p)
        (add-hook 'before-save-hook #'format/lsp-before-save nil t)
      (add-hook 'before-save-hook #'format/initialize-on-first-save nil t))))

(defun format/use-lsp-p ()
  "Whether formatting needs the language server's project metadata."
  (derived-mode-p 'java-mode 'java-ts-mode 'rust-mode 'rust-ts-mode))

(defun format/lsp-before-save ()
  "Honor Java formatter settings and Rust's Cargo edition through LSP."
  (when (and (not (my-large-buffer-p))
             (bound-and-true-p lsp-mode)
             (lsp-feature? "textDocument/formatting"))
    (lsp-format-buffer)))

(defun format/region-or-buffer ()
  "Format the region or buffer with its language's configured formatter."
  (interactive)
  (if (format/use-lsp-p)
      (format/lsp-region-or-buffer)
    (call-interactively #'format-all-region-or-buffer)))

(defun format/with-project-tools (original &rest args)
  "Run ORIGINAL with nearby Node tools taking precedence over fallback tools."
  (let* ((root (and buffer-file-name
                    (locate-dominating-file buffer-file-name "node_modules/.bin")))
         (bin (and root (expand-file-name "node_modules/.bin" root)))
         (exec-path (if bin (cons bin exec-path) exec-path))
         (process-environment (copy-sequence process-environment)))
    (when bin (setenv "PATH" (concat bin path-separator (getenv "PATH"))))
    (apply original args)))

(my-use-package! format-all
  :commands format-all-mode
  :diminish format-all-mode
  :bind
  ("C-M-\\" . format/region-or-buffer)
  :hook
  (prog-mode . format/prepare-on-save)
  (text-mode . format/prepare-on-save)
  :init
  (add-hook 'format-all-mode-hook #'format/cancel-pending-setup)
  (add-to-list 'auto-mode-alist '("\\.jsonc\\'" . js-json-mode))
  (with-eval-after-load 'language-id
    (format/register-mode "JSON" 'js-json-mode)
    (format/register-mode "Shell" 'bash-ts-mode)
    (format/register-mode "TOML" 'toml-ts-mode)
    (format/register-mode "YAML" 'yaml-ts-mode)
    (format/register-mode "Swift" 'swift-ts-mode)
    (format/register-mode "Typst" 'typst-ts-mode))
  :config
  ;; Upstream shfmt appends .bash to filenames, which breaks [*.sh]
  ;; EditorConfig sections.  Preserve the real filename and shebang detection.
  (define-format-all-formatter project-shfmt
    (:executable "shfmt")
    (:install (macos "brew install shfmt"))
    (:languages "Shell")
    (:features)
    (:format (format-all--buffer-easy
              executable
              (when buffer-file-name (list "--filename" buffer-file-name)))))
  (setq-default format-all-formatters
                '(("C" clang-format)
                  ("C++" clang-format)
                  ("CSS" prettier)
                  ("Dockerfile" dockfmt)
                  ("Emacs Lisp" emacs-lisp)
                  ("Go" gofmt)
                  ("HTML" prettier)
                  ("JavaScript" prettier)
                  ("JSON" prettier)
                  ("JSON5" prettier)
                  ("JSX" prettier)
                  ("Markdown" prettier)
                  ("Python" black)
                  ("Rust" rustfmt)
                  ("SCSS" prettier)
                  ("Shell" project-shfmt)
                  ("Swift" swiftformat)
                  ("TSX" prettier)
                  ("TypeScript" prettier)
                  ("TOML" taplo-fmt)
                  ("Vue" prettier)
                  ("XML" html-tidy)
                  ("YAML" prettier)))
  (setq format-all-show-errors 'errors)
  (advice-add 'format-all--command-args :around #'format/with-project-tools)
  (advice-add 'format-all--run-chain :around #'format/with-project-tools))

(provide 'my-plugins-format-all)
;;; format-all.el ends here
