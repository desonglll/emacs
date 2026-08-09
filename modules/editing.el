;;; editing.el --- Editing and navigation packages -*- lexical-binding: t; -*-

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

(my-use-package! translate
  :commands (translate-trans translate-argo))

(provide 'my-editing)
;;; editing.el ends here
