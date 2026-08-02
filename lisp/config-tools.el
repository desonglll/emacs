;;; config-tools.el --- Development and productivity tools -*- lexical-binding: t; -*-

;;;; Version control and LSP

(use-package magit
  :commands (magit-status magit-dispatch)
  :bind
  (("C-x g" . magit-status)
   ("C-x M-g" . magit-dispatch)))

(use-package lsp-mode
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

(my-use-git-package kill-other-buffers github
  "desonglll/kill-other-buffers.el"
  :commands kill-other-buffers)

;;;; AI and translation

(use-package gptel
  :commands (gptel gptel-send gptel-menu))

(my-use-git-package translate github
  "desonglll/translate.el"
  :commands (translate-trans translate-argo))

(provide 'config-tools)
;;; config-tools.el ends here
