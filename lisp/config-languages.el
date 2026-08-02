;;; config-languages.el --- Input methods and language modes -*- lexical-binding: t; -*-

;;;; Chinese input

(use-package pyim
  :commands pyim-convert-string-at-point
  :init
  (setq default-input-method "pyim")
  :config
  (pyim-default-scheme 'quanpin))

(use-package pyim-basedict
  :after pyim
  :config
  (pyim-basedict-enable))

;;;; Language modes

(use-package just-mode
  :mode ("\\(?:^\\|/\\)[Jj]ustfile\\'" . just-mode))

(use-package protobuf-mode
  :mode ("\\.proto\\'" . protobuf-mode))

(defun my-typst-start-lsp ()
  "Start Tinymist for the current Typst buffer when it is installed."
  (if (executable-find "tinymist")
      (lsp-deferred)
    (message "Tinymist is not installed; skipping Typst LSP")))

(my-use-git-package typst-ts-mode codeberg
  "meow_king/typst-ts-mode"
  :mode ("\\.typ\\'" . typst-ts-mode)
  :hook
  (typst-ts-mode . my-typst-start-lsp))

(provide 'config-languages)
;;; config-languages.el ends here
