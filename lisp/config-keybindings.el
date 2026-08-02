;;; config-keybindings.el --- Personal global key bindings -*- lexical-binding: t; -*-

(dolist (binding
         '(("M-<f1>" . magit-status)
           ("M-<f2>" . dirvish)
           ("C-," . duplicate-line)
           ("C-:" . avy-goto-char-2)
           ("s-\\" . avy-goto-char-2)
           ("M-#" . consult-fd)
           ("C-c r" . consult-ripgrep)
           ("s-u" . revert-buffer)
           ("s-i" . imenu-list)
           ("s-e" . treemacs)
           ("M-o" . ace-window)
           ("C-c RET" . ffap)))
  (keymap-global-set (car binding) (cdr binding)))

(provide 'config-keybindings)
;;; config-keybindings.el ends here
