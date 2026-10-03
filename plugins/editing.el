;;; editing.el --- Editing package configuration -*- lexical-binding: t; -*-

;;;; Snippets

(my-use-package! yasnippet
  :demand t
  :config
  (yas-global-mode 1))

;;;; Navigation and buffers

(my-use-package! ace-window
  :commands ace-window)

(my-use-package! avy
  :commands avy-goto-char-2)

;;;; Input and text

(my-use-package! pyim
  :commands pyim-convert-string-at-point
  :init
  (setq default-input-method "pyim")
  :config
  (pyim-default-scheme 'quanpin))

(my-use-package! pyim-basedict
  :after pyim
  :config
  (pyim-basedict-enable))

(my-use-package! pyim-tsinghua-dict
  :after pyim
  :config
  (pyim-tsinghua-dict-enable))

(my-use-package! translate
  :commands (translate-trans translate-argo translate-volcengine translate-volcengine-ark)
  :init
  (setq translate-volcengine-api-key
        (or (getenv "VOLCENGINE_TRANSLATE_API_KEY")
            (getenv "VOLCENGINE_API_KEY")))
  (setq translate-volcengine-ark-api-key
        (or (getenv "ARK_API_KEY")
            (getenv "VOLCENGINE_ARK_API_KEY"))))

(my-use-package! diff-hl
  :hook ((prog-mode . diff-hl-mode)
         (text-mode . diff-hl-mode))
  :config
  (global-diff-hl-mode)
  (diff-hl-flydiff-mode)
  )

(provide 'my-plugins-editing)
;;; editing.el ends here
