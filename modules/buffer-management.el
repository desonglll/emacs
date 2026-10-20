;;; buffer-management.el --- Workspace cleanup and grouped buffers -*- lexical-binding: t; -*-

(defun my/kill-other-buffers (&optional force)
  "Close other unmodified user buffers in the current workspace.
Shared buffers are only detached from this workspace.  Terminals, process
buffers and internal buffers are always preserved.  With prefix FORCE,
also consider modified buffers, using the normal save/discard prompt."
  (interactive "P")
  (let* ((current (current-buffer))
         (workspace (bound-and-true-p persp-mode))
         (buffers (copy-sequence (if workspace (persp-current-buffers) (buffer-list))))
         (closed 0))
    (save-current-buffer
      (dolist (buffer buffers)
        (when (and (buffer-live-p buffer)
                   (not (eq buffer current))
                   (with-current-buffer buffer
                     (and (not (string-prefix-p " " (buffer-name)))
                          (not (string-prefix-p "*" (buffer-name)))
                          (not (get-buffer-process buffer))
                          (not (derived-mode-p 'eat-mode 'term-mode 'comint-mode
                                               'compilation-mode 'special-mode))
                          (or (not (buffer-modified-p))
                              (and force
                                   (or buffer-file-name
                                       (y-or-n-p (format "Discard changes in %s? "
                                                         (buffer-name)))))))))
          (if workspace (persp-remove-buffer buffer) (kill-buffer buffer))
          (when (or (not (buffer-live-p buffer))
                    (and workspace (not (memq buffer (persp-current-buffers)))))
            (cl-incf closed)))))
    (message "Closed %d buffer%s in this workspace" closed (if (= closed 1) "" "s"))))

(defvar-local my-ibuffer-project-root nil
  "Project identity refreshed when opening or refreshing Ibuffer.")

(defun my-ibuffer-project-groups ()
  "Group local file buffers by project, without probing remote hosts."
  (let (roots)
    (dolist (buffer (buffer-list))
      (with-current-buffer buffer
        (setq my-ibuffer-project-root nil)
        (when (and (or buffer-file-name (derived-mode-p 'dired-mode))
                   (not (file-remote-p default-directory)))
          (when-let ((project (project-current nil)))
            (setq my-ibuffer-project-root (file-truename (project-root project)))
            (cl-pushnew my-ibuffer-project-root roots :test #'equal)))))
    (append
     '(("Unsaved files" (and (modified) (visiting-file)))
       ("Terminals" (or (mode . eat-mode) (mode . term-mode) (mode . shell-mode)))
       ("Remote" (predicate . (file-remote-p default-directory))))
     ;; Compare project identities, so nested projects and symlinked paths work.
     (mapcar (lambda (root)
               (list (abbreviate-file-name root)
                     (cons 'predicate `(equal my-ibuffer-project-root ,root))))
             (sort roots #'string<)))))

(defun my-ibuffer-refresh (&optional arg)
  "Refresh project groups and buffers, passing prefix ARG to Ibuffer."
  (interactive "P")
  (setq ibuffer-filter-groups (my-ibuffer-project-groups))
  (ibuffer-update arg))

(with-eval-after-load 'ibuffer
  (define-key ibuffer-mode-map [remap ibuffer-update] #'my-ibuffer-refresh))

(defun my/list-buffers-focus (&optional full-frame)
  "Open project-grouped Ibuffer; with FULL-FRAME, use the whole frame."
  (interactive "P")
  (require 'ibuffer)
  (ibuffer nil "*Ibuffer*" nil nil nil (my-ibuffer-project-groups))
  (when full-frame (delete-other-windows)))

(provide 'my-buffer-management)
;;; buffer-management.el ends here
