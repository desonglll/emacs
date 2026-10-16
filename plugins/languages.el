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

;; Native Tree-sitter associations take precedence when grammars are ready.
(my-use-package! typescript-mode :mode "\\.[cm]?ts\\'")
(my-use-package! yaml-mode :mode "\\.ya?ml\\'")
(my-use-package! toml-mode :mode "\\.toml\\'")

(my-use-package! web-mode
  :mode "\\.vue\\'"
  :custom
  (web-mode-markup-indent-offset 2)
  (web-mode-code-indent-offset 2)
  (web-mode-css-indent-offset 2)
  ;; LSP supplies embedded TypeScript diagnostics and completion.
  (web-mode-enable-auto-quoting nil))

(my-refresh-treesit-mode-remaps)

(defun format/lsp-region-or-buffer ()
  "Format the active region or current buffer through LSP."
  (interactive)
  (if (use-region-p)
      (lsp-format-region (region-beginning) (region-end))
    (lsp-format-buffer)))

(defun my-typst-start-lsp ()
  "Start Tinymist for the current Typst buffer when it is installed."
  (unless (my-large-buffer-p)
    (if (executable-find "tinymist")
        (lsp-deferred)
      (message "Tinymist is not installed; skipping Typst LSP"))))

(my-use-package! typst-ts-mode
  :mode ("\\.typ\\'" . typst-ts-mode)
  :bind
  (:map typst-ts-mode-map
        ("C-M-\\" . format/lsp-region-or-buffer))
  :hook
  (typst-ts-mode . my-typst-start-lsp))

(provide 'my-plugins-languages)
;;; languages.el ends here
