;;; file-actions.el --- File paths and native file navigation -*- lexical-binding: t; -*-

(defun my-file-action-target ()
  "Return the file at point in Dired, or the file visited by this buffer."
  (if (derived-mode-p 'dired-mode)
      (or (dired-get-filename nil t) default-directory)
    (or buffer-file-name (user-error "This buffer is not visiting a file"))))

(defun my-copy-file-path (&optional project-relative)
  "Copy the current file's absolute path.
With prefix PROJECT-RELATIVE, copy its path relative to the project root."
  (interactive "P")
  (let* ((file (my-file-action-target))
         (project (and project-relative (project-current nil)))
         (path (if project-relative
                   (if project
                       ;; macOS aliases /var to /private/var; project.el may
                       ;; return the real root while the buffer uses the alias.
                       (file-relative-name (file-truename file)
                                           (file-truename (project-root project)))
                     (user-error "This file is not in a project"))
                 (expand-file-name file))))
    (kill-new path)
    (message "Copied: %s" path)))

(defun my-copy-project-file-path ()
  "Copy the current file's project-relative path."
  (interactive)
  (my-copy-file-path t))

(defun my-reveal-in-finder ()
  "Reveal the current local file or Dired entry in macOS Finder."
  (interactive)
  (let ((file (my-file-action-target)))
    (unless (eq system-type 'darwin) (user-error "Finder is available on macOS"))
    (when (file-remote-p file) (user-error "Finder cannot reveal a remote file"))
    (unless (file-exists-p file) (user-error "This file has not been saved yet"))
    (start-process "reveal-in-finder" nil "/usr/bin/open" "-R"
                   (expand-file-name file))))

(provide 'my-file-actions)
;;; file-actions.el ends here
