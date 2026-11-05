;;; ghostel.el --- Ghostty-powered terminal configuration -*- lexical-binding: t; -*-

(defun my-ghostel-buffer-setup ()
  "Keep terminal output free of editor decorations and completion popups."
  (display-line-numbers-mode -1)
  (setq-local show-trailing-whitespace nil
              company-idle-delay nil))

(my-use-package! ghostel
  :commands (ghostel ghostel-new ghostel-list-buffers)
  :bind ("C-c t g" . ghostel)
  :hook (ghostel-mode . my-ghostel-buffer-setup)
  :custom
  (ghostel-module-directory (expand-file-name "ghostel/" my-state-directory))
  (ghostel-module-auto-install 'download)
  :config
  (keymap-set ghostel-mode-map "s-c" #'ghostel-readonly-copy)
  (keymap-set ghostel-mode-map "s-v" #'ghostel-yank)
  (keymap-set ghostel-semi-char-mode-map "M-w" #'ghostel-readonly-copy))

(my-use-package! ghostel-project
  :commands (ghostel-project ghostel-project-list-buffers))

(provide 'my-plugins-ghostel)
;;; ghostel.el ends here
