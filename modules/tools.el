;;; tools.el --- Development and productivity packages -*- lexical-binding: t; -*-

;;;; Version control and LSP

(my-use-package! magit
  :commands (magit-status magit-dispatch)
  :bind
  (("C-x g" . magit-status)
   ("C-x M-g" . magit-dispatch)))

(my-use-package! lsp-mode
  :commands (lsp lsp-deferred)
  :init
  (setq lsp-keymap-prefix "C-c l")
  :custom
  (lsp-session-file (expand-file-name "lsp-session-v1" my-state-directory))
  ;; lsp-completion-mode still installs its CAPF; Corfu supplies the UI.
  (lsp-completion-provider :none)
  (lsp-diagnostics-provider :flymake)
  (lsp-enable-snippet nil)
  (lsp-headerline-breadcrumb-enable nil)
  (lsp-idle-delay 0.5)
  (lsp-keep-workspace-alive nil)
  (lsp-lens-enable nil)
  (lsp-log-io nil))

;;;; Navigation and buffers

(my-use-package! ace-window
  :commands ace-window)

(my-use-package! avy
  :commands avy-goto-char-2)

(my-use-package! dirvish
  :commands dirvish)

(my-use-package! imenu-list
  :commands imenu-list)

(my-use-package! treemacs
  :commands treemacs)

(my-use-package! kill-other-buffers
  :commands kill-other-buffers)

;;;; AI and translation

(my-use-package! gptel
  :commands (gptel gptel-send gptel-menu))

(my-use-package! translate
  :commands (translate-trans translate-argo))

(provide 'my-tools)
;;; tools.el ends here
