;;; kotlin-lsp.el --- JetBrains Kotlin language server -*- lexical-binding: t; -*-

(require 'lsp-mode)

(defun my-kotlin-import-log (workspace params)
  "Record import PARAMS and refresh WORKSPACE diagnostics after import."
  (lsp-log "Kotlin import: %s" params)
  ;; lsp-mode asks for pull diagnostics before this server imports its project.
  ;; Ask again when the imported source roots and dependencies are available.
  (when (lsp-get params :succeeded)
    (dolist (buffer (lsp--workspace-buffers workspace))
      (when (buffer-live-p buffer)
        (with-current-buffer buffer
          (lsp-diagnostics--request-pull-diagnostics workspace))))))

;; The current official launcher supports the standard stdio transport.
(lsp-register-client
 (make-lsp-client
  :new-connection (lsp-stdio-connection '("kotlin-lsp" "--stdio"))
  :activation-fn (lsp-activate-on "kotlin")
  :major-modes '(kotlin-mode)
  :notification-handlers
  (lsp-ht ("intellij/workspaceImportStatus" #'ignore)
          ("intellij/workspaceImportState" #'ignore)
          ("intellij/ready-for-test" #'ignore)
          ("intellij/importLog" #'my-kotlin-import-log))
  :server-id 'kotlin-jetbrains))

(provide 'my-kotlin-lsp)
;;; kotlin-lsp.el ends here
