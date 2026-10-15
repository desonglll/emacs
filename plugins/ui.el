;;; ui.el --- User interface package configuration -*- lexical-binding: t; -*-

(my-use-package! dirvish
  :commands dirvish)

(my-use-package! imenu-list
  :commands imenu-list)

(my-use-package! treemacs
  :commands treemacs
  :config
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
