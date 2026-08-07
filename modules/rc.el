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


(defun my/kill-other-buffers (&optional arg)
  "Kill other unmodified buffers.

With prefix argument FORCE, also include internal buffers and ask
before killing modified buffers."
  (interactive "P")
  (let ((current-buffer (current-buffer))
        (killed-count 0))
    (dolist (buffer (buffer-list))
      (unless (eq buffer current-buffer)
        (let ((name (buffer-name buffer)))
          (when (and name
                     (or arg
                         (not (string-prefix-p " " name)))
                     (or (not (buffer-modified-p buffer))
                         (if arg
                             (y-or-n-p
                              (format "Kill modified buffer `%s'? " name))
                           )
                         ))
            (when (kill-buffer buffer)
              (setq killed-count (1+ killed-count)))))))
    (message "Killed %d buffer%s"
             killed-count
             (if (= killed-count 1) "" "s"))))

(defun my/list-buffers-focus ()
  "List buffers and focus."
  (interactive)
  (list-buffers)
  (pop-to-buffer "*Buffer List*")
  (delete-other-windows)
  )

;;; rc.el ends here.
