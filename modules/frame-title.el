;;; frame-title.el --- Concise, cached window titles -*- lexical-binding: t; -*-

(defvar-local my-ui-title-project nil
  "Cached project label; never look up projects while redisplaying a frame.")

(defun my-ui-cache-title-project ()
  "Refresh the project label when visiting a file or entering a browser."
  (setq my-ui-title-project
        (unless (file-remote-p default-directory)
          (when-let ((project (project-current nil)))
            (file-name-nondirectory
             (directory-file-name (project-root project)))))))

(defun my-ui-frame-title ()
  "Describe the selected buffer without exposing internal sidebar names."
  (with-current-buffer
      (window-buffer (or (minibuffer-selected-window) (selected-window)))
    (let ((label (cond
                  ((derived-mode-p 'treemacs-mode 'dired-mode) "Files")
                  ((derived-mode-p 'imenu-list-major-mode) "Outline")
                  ((derived-mode-p 'eat-mode) "Terminal")
                  (buffer-file-name (file-name-nondirectory buffer-file-name))
                  ((equal (buffer-name) "*scratch*") "Scratch")
                  (t (string-trim (buffer-name) "\\*+" "\\*+")))))
      (format "%s · %s" label (or my-ui-title-project "Emacs")))))

(dolist (hook '(find-file-hook dired-mode-hook treemacs-mode-hook
                imenu-list-major-mode-hook eat-mode-hook))
  (add-hook hook #'my-ui-cache-title-project))

(setq frame-title-format '(:eval (my-ui-frame-title))
      icon-title-format frame-title-format)

(provide 'my-frame-title)
;;; frame-title.el ends here
