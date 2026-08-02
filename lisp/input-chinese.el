;;; input-chinese.el --- Chinese input method -*- lexical-binding: t; -*-

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

(provide 'input-chinese)
;;; input-chinese.el ends here
