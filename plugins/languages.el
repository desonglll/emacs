;;; languages.el --- Language mode package configuration -*- lexical-binding: t; -*-

(my-use-package! rust-mode
  :mode "\\.rs\\'")

(my-use-package! go-mode
  :mode "\\.go\\'")

(my-use-package! swift-mode
  :mode "\\.swift\\(?:interface\\)?\\'")

(my-use-package! swift-ts-mode
  :commands swift-ts-mode)

(my-use-package! just-mode
  :mode ("\\(?:^\\|/\\)[Jj]ustfile\\'" . just-mode))

(my-use-package! protobuf-mode
  :mode ("\\.proto\\'" . protobuf-mode))

(defun format/lsp-region-or-buffer ()
  "Format the active region or current buffer through LSP."
  (interactive)
  (if (use-region-p)
      (lsp-format-region (region-beginning) (region-end))
    (lsp-format-buffer)))

(defun my-typst-start-lsp ()
  "Start Tinymist for the current Typst buffer when it is installed."
  (if (executable-find "tinymist")
      (lsp-deferred)
    (message "Tinymist is not installed; skipping Typst LSP")))

(my-use-package! typst-ts-mode
  :mode ("\\.typ\\'" . typst-ts-mode)
  :bind
  (:map typst-ts-mode-map
        ("C-M-\\" . format/lsp-region-or-buffer))
  :hook
  (typst-ts-mode . my-typst-start-lsp))

(provide 'my-plugins-languages)
;;; languages.el ends here
