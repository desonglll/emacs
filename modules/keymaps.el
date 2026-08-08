
;;; keymaps.el --- keymap configuration -*- lexical-binding: t; -*-

;;;; Global key bindings

(dolist (binding
         '(("M-<f2>" . dirvish)
           ("C-," . duplicate-line)
           ("C-:" . avy-goto-char-2)
           ("s-\\" . avy-goto-char-2)
           ("s-u" . revert-buffer)
           ("s-i" . imenu-list)
           ("s-e" . treemacs)
           ("M-o" . ace-window)
           ("C-c RET" . ffap)
           ("C-c f r" . recentf)
           ("C-c f f" . consult-fd)
           ("C-c f g" . consult-ripgrep)
           ("s-<return>" . my/new-buffer)
           ("C-<tab>" . next-buffer)
           ("C-S-<tab>" . previous-buffer)
           ("C-<iso-lefttab>" . previous-buffer)
           ("C-c b" . my/list-buffers-focus)
           ))
  (keymap-global-set (car binding) (cdr binding)))

;;; keymaps.el ends here.
