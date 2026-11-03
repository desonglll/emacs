;;; diagnostics.el --- Shared Flycheck diagnostics -*- lexical-binding: t; -*-

(defun my-flycheck-disable-flymake ()
  "Use one diagnostics display when Flycheck is enabled."
  (when (and (bound-and-true-p flycheck-mode)
             (bound-and-true-p flymake-mode))
    (flymake-mode -1)))

(defun my-flycheck-inline-display ()
  "Keep inline diagnostic messages in sync with Flycheck in this buffer."
  (flycheck-annotate-mode (if flycheck-mode 1 -1)))

(defun my-enable-file-flycheck ()
  "Check ordinary local files not already assigned to a language server."
  ;; lsp-mode enables Flycheck itself once its server is ready.  Waiting avoids
  ;; starting a standalone checker, such as Cargo, during server initialization.
  (when (and buffer-file-name
             (not (or (file-remote-p buffer-file-name) (my-large-buffer-p)))
             (not (alist-get major-mode (bound-and-true-p my-lsp-language-clients))))
    (require 'flycheck)
    (when (flycheck-may-enable-mode)
      (flycheck-mode 1))))

(defun my-flycheck-show-errors (&optional project)
  "Show current-buffer errors, or project errors when PROJECT is non-nil."
  (interactive "P")
  (require 'flycheck)
  (flycheck-list-errors)
  (with-current-buffer flycheck-error-list-buffer
    (setq-local flycheck-error-list-scope (if project 'project 'buffer))
    (flycheck-error-list-refresh)))

(defun my-flycheck-show-project-errors ()
  "Show Flycheck diagnostics collected for the current project."
  (interactive)
  (my-flycheck-show-errors t))

(my-use-package! flycheck
  :commands (flycheck-mode flycheck-list-errors)
  :hook
  ((flycheck-mode . my-flycheck-disable-flymake)
   (flycheck-mode . my-flycheck-inline-display))
  :bind
  (("C-c d b" . my-flycheck-show-errors)
   ("C-c d p" . my-flycheck-show-project-errors))
  :custom
  (flycheck-idle-change-delay 0.5)
  (flycheck-annotate-current-line-style 'below)
  (flycheck-annotate-other-lines-style 'eol)
  (flycheck-annotate-background nil))

;; Run after local variables and the language-server routing hook.
(add-hook 'hack-local-variables-hook #'my-enable-file-flycheck 95)

(provide 'my-plugins-diagnostics)
;;; diagnostics.el ends here
