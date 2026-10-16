;;; workspace-state.el --- Durable file workspaces -*- lexical-binding: t; -*-

(defvar my-workspace-state-ready nil
  "Non-nil after a normal interactive session is ready to save its workspaces.")

(setq persp-state-default-file
      (expand-file-name "workspaces.el" my-state-directory))

(defun my-workspace-restore ()
  "Restore saved workspaces when startup did not explicitly visit a file."
  (unless (or noninteractive (daemonp))
    (condition-case err
        (progn
          (when (and (file-readable-p persp-state-default-file)
                     (not (seq-some #'buffer-file-name (buffer-list))))
            (persp-state-load persp-state-default-file))
          (setq my-workspace-state-ready t))
      (error
       ;; Preserve the last saved session if it could not be restored.
       (display-warning 'workspace (error-message-string err))))))

(defun my-workspace-save ()
  "Atomically save interactive workspaces, preserving the previous snapshot."
  (when (and (not noninteractive) my-workspace-state-ready persp-mode)
    (let ((temporary (make-temp-file
                      (expand-file-name ".workspaces-" my-state-directory))))
      (unwind-protect
          (condition-case err
              (progn
                (let ((persp-state-default-file temporary))
                  (persp-state-save))
                (when (file-exists-p persp-state-default-file)
                  (copy-file persp-state-default-file
                             (concat persp-state-default-file ".bak") t))
                (rename-file temporary persp-state-default-file t))
            (error (display-warning 'workspace (error-message-string err))))
        (when (file-exists-p temporary) (delete-file temporary))))))

(add-hook 'emacs-startup-hook #'my-workspace-restore 90)
(add-hook 'kill-emacs-hook #'my-workspace-save)

(provide 'my-workspace-state)
;;; workspace-state.el ends here
