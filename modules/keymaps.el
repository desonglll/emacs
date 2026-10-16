;;; keymaps.el --- keymap configuration -*- lexical-binding: t; -*-

;;;; Global key bindings

(dolist (binding
         '(("M-<f2>" . dired-jump)
           ("C-," . duplicate-line)
           ("C-:" . avy-goto-char-2)
           ("s-\\" . avy-goto-char-2)
           ("s-u" . revert-buffer)
           ("s-i" . imenu-list)
           ("s-e" . treemacs)
           ("M-o" . ace-window)
           ("C-c RET" . ffap)
           ("C-c f r" . my-recentf)
           ("C-c f f" . consult-fd)
           ("C-c f g" . consult-ripgrep)
           ("C-c f y" . my-copy-file-path)
           ("C-c f Y" . my-copy-project-file-path)
           ("C-c f o" . my-reveal-in-finder)
           ("C-c f R" . rename-visited-file)
           ("s-<return>" . my/new-buffer)
           ("C-<tab>" . next-buffer)
           ("C-S-<tab>" . previous-buffer)
           ("C-<iso-lefttab>" . previous-buffer)
           ("C-c b" . my/list-buffers-focus)
           ("M-<return>" . delete-other-windows)
           ))
  (keymap-global-set (car binding) (cdr binding)))

(which-key-add-key-based-replacements
  "C-c f" "Files"
  "C-c w" "Workspace"
  "C-c p" "Project"
  "C-c t" "Terminal / Toggles"
  "C-c d" "Diagnostics"
  "C-c l" "Language"
  "C-c c" "Completion"
  "C-c E" "Environment")

;;; keymaps.el ends here.
