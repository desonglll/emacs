;;; workspace-state.el --- Explicit workspace snapshots -*- lexical-binding: t; -*-

(setq persp-state-default-file
      (expand-file-name "workspaces.el" my-state-directory))

(defun my-workspace-save ()
  "Manually save workspaces atomically, preserving the previous snapshot."
  (interactive)
  (unless persp-mode (user-error "Workspace 模式未开启"))
  (let ((temporary (make-temp-file
                    (expand-file-name ".workspaces-" my-state-directory))))
    (unwind-protect
        (progn
          (let ((persp-state-default-file temporary))
            (persp-state-save))
          (when (file-exists-p persp-state-default-file)
            (copy-file persp-state-default-file
                       (concat persp-state-default-file ".bak") t))
          (rename-file temporary persp-state-default-file t)
          (message "Workspace 已保存"))
      (when (file-exists-p temporary) (delete-file temporary)))))

;; Remove the former automatic behavior when reloading an existing session.
(remove-hook 'emacs-startup-hook #'my-workspace-restore)
(remove-hook 'kill-emacs-hook #'my-workspace-save)
(advice-remove 'persp-state-load #'my-workspace-adopt-snapshot)
(advice-remove 'persp-state-save #'my-workspace-adopt-snapshot)

(keymap-set perspective-map "C-s" #'my-workspace-save)

(provide 'my-workspace-state)
;;; workspace-state.el ends here
