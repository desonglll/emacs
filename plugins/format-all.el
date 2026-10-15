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
    (add-hook 'before-save-hook #'format/initialize-on-first-save nil t)))

(my-use-package! format-all
  :commands format-all-mode
  :diminish format-all-mode
  :bind
  ("C-M-\\" . format-all-region-or-buffer)
  :hook
  (prog-mode . format/prepare-on-save)
  (text-mode . format/prepare-on-save)
  :init
  (add-hook 'format-all-mode-hook #'format/cancel-pending-setup)
  (add-to-list 'auto-mode-alist '("\\.jsonc\\'" . js-json-mode))
  (with-eval-after-load 'language-id
    (format/register-mode "JSON" 'js-json-mode)
    (format/register-mode "Swift" 'swift-ts-mode)
    (format/register-mode "Typst" 'typst-ts-mode))
  :config
  (setq-default format-all-formatters
                '(("C" (clang-format "--style=LLVM"))
                  ("C++" (clang-format "--style=LLVM"))
                  ("CSS" prettier)
                  ("Dockerfile" dockfmt)
                  ("Emacs Lisp" emacs-lisp)
                  ("Go" gofmt)
                  ("HTML" prettier)
                  ("Java" google-java-format)
                  ("JavaScript" prettier)
                  ("JSON" prettier)
                  ("JSON5" prettier)
                  ("JSX" prettier)
                  ("Markdown" prettier)
                  ("Python" (black "--line-length" "88"))
                  ("Rust" rustfmt)
                  ("SCSS" prettier)
                  ("Shell" (shfmt "-i" "2"))
                  ("Swift" swiftformat)
                  ("TSX" prettier)
                  ("TypeScript" prettier)
                  ("Vue" prettier)
                  ("XML" html-tidy)
                  ("YAML" prettier)))
  (setq format-all-show-errors 'errors))

(provide 'my-plugins-format-all)
;;; format-all.el ends here
