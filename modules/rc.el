;;; rc.el --- my custom functions -*- lexical-binding: t; -*-

(defun my/current-buffer ()
  (interactive)
  (message "current buffer: %s" buffer-file-name)
  )

(defun my/new-buffer ()
  "Create a new buffer in the selected window."
  (interactive)
  (let ((buffer (generate-new-buffer "*new*")))
    (set-window-buffer nil buffer)
    (with-current-buffer buffer
      (funcall (default-value 'major-mode)))))

(defun my/open-config ()
  "Open the main Emacs configuration file."
  (interactive)
  (find-file (expand-file-name "config.el" my-config-directory)))


;;; rc.el ends here.
