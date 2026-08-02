;;; language-modes.el --- Additional language modes -*- lexical-binding: t; -*-

(use-package just-mode
  :mode ("\\(?:^\\|/\\)[Jj]ustfile\\'" . just-mode))

(use-package protobuf-mode
  :mode ("\\.proto\\'" . protobuf-mode))

(defun my-typst-start-lsp ()
  "Start Tinymist for the current Typst buffer when it is installed."
  (if (executable-find "tinymist")
      (lsp-deferred)
    (message "Tinymist is not installed; skipping Typst LSP")))

(use-package typst-ts-mode
  :straight
  (typst-ts-mode
   :type git
   :host codeberg
   :repo "meow_king/typst-ts-mode")
  :mode ("\\.typ\\'" . typst-ts-mode)
  :hook
  (typst-ts-mode . my-typst-start-lsp))

(provide 'language-modes)
;;; language-modes.el ends here
