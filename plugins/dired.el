;;; dired.el --- Git status in directory listings -*- lexical-binding: t; -*-

(defun my-dired-git-setup ()
  "Show asynchronous Git indicators in local Dired and Dirvish buffers."
  (unless (file-remote-p default-directory)
    (require 'diff-hl-dired)
    (diff-hl-dired-mode 1)
    (add-hook 'window-selection-change-functions
              #'my-dired-git-refresh-visible nil t)
    (add-hook 'window-buffer-change-functions
              #'my-dired-git-refresh-visible nil t)))

(defun my-dired-git-refresh-visible (window)
  "Refresh Git status when a Dired buffer becomes the selected window.
Checking on selection also catches changes made in an external terminal."
  (with-current-buffer (window-buffer window)
    (when (and (eq window (frame-selected-window (window-frame window)))
               (bound-and-true-p diff-hl-dired-mode)
               (not (file-remote-p default-directory))
               (not (buffer-live-p diff-hl-dired-process-buffer)))
      (diff-hl-dired-update))))

(defun my-dired-git-refresh-after-save ()
  "Update open parent directories after saving a local file."
  (when (and buffer-file-name (not (file-remote-p buffer-file-name)))
    (let ((file buffer-file-name))
      (dolist (buffer (buffer-list))
        (with-current-buffer buffer
          (when (and (bound-and-true-p diff-hl-dired-mode)
                     (not (file-remote-p default-directory))
                     (file-in-directory-p file default-directory))
            (diff-hl-dired-update)))))))

(my-use-package! diff-hl-dired
  :commands diff-hl-dired-mode
  :hook (dired-mode . my-dired-git-setup)
  :custom
  ;; Keep untracked/new files, but skip ignored files and their extra scan.
  (diff-hl-dired-extra-indicators nil)
  :config
  (add-hook 'after-save-hook #'my-dired-git-refresh-after-save))

(provide 'my-plugins-dired)
;;; dired.el ends here
