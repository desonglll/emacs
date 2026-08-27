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
  :commands (translate-trans translate-argo))

(provide 'my-plugins-editing)
;;; editing.el ends here
