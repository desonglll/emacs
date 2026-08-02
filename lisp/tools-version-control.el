;;; tools-version-control.el --- Version control tools -*- lexical-binding: t; -*-

(use-package magit
  :commands (magit-status magit-dispatch)
  :bind
  (("C-x g" . magit-status)
   ("C-x M-g" . magit-dispatch)))

(provide 'tools-version-control)
;;; tools-version-control.el ends here
