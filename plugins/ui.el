;;; ui.el --- User interface package configuration -*- lexical-binding: t; -*-

(my-use-package! dirvish
  :commands dirvish
  :custom
  ;; Dirvish adds one pixel; keep enough room for the shared Git gutter.
  (dirvish-window-fringe (1- (alist-get 'left-fringe my-ui-frame-spacing))))

(defun my-sidebar-highlight ()
  "Use the shared selection color in directory and outline buffers."
  (setq-local hl-line-face 'my-sidebar-selection))

(add-hook 'dired-mode-hook #'my-sidebar-highlight)

(my-use-package! imenu-list
  :commands imenu-list
  :hook (imenu-list-major-mode . my-sidebar-highlight)
  :custom
  (imenu-list-size 32)
  (imenu-list-auto-resize nil))

(my-use-package! treemacs
  :commands treemacs
  :custom
  (treemacs-width 32)
  (treemacs-follow-after-init t)
  (treemacs-file-follow-delay 0.3)
  :config
  (treemacs-follow-mode 1)
  (defun my-treemacs-initialize-empty-workspace (toggle &optional arg)
    "Open the current project when TOGGLE would show an empty workspace.
Keep prefix ARG's workspace selection and the usual toggle for populated trees."
    (if (or arg
            (treemacs-workspace->projects (treemacs-current-workspace)))
        (funcall toggle arg)
      (treemacs-add-and-display-current-project)))
  (advice-add 'treemacs :around #'my-treemacs-initialize-empty-workspace))

(my-use-package! helpful
  :bind
  (("C-h f" . helpful-callable)
   ("C-h v" . helpful-variable)
   ("C-h k" . helpful-key)
   ("C-h x" . helpful-command)))

(my-use-package! pdf-tools
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :config
  (pdf-tools-install))

(provide 'my-plugins-ui)
;;; ui.el ends here
