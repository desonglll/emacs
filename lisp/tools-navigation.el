;;; tools-navigation.el --- Navigation and buffer tools -*- lexical-binding: t; -*-

(use-package ace-window
  :commands ace-window)

(use-package avy
  :commands avy-goto-char-2)

(use-package dirvish
  :commands dirvish)

(use-package imenu-list
  :commands imenu-list)

(use-package treemacs
  :commands treemacs)

(use-package kill-other-buffers
  :straight
  (kill-other-buffers
   :type git
   :host github
   :repo "desonglll/kill-other-buffers.el")
  :commands kill-other-buffers)

(provide 'tools-navigation)
;;; tools-navigation.el ends here
