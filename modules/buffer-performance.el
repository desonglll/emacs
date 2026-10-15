;;; buffer-performance.el --- Large buffer policy -*- lexical-binding: t; -*-

(defvar my-large-buffer-threshold (* 2 1024 1024)
  "Buffer size in bytes above which automatic editing extras are skipped.")

(defun my-large-buffer-p ()
  "Return non-nil when the entire buffer exceeds `my-large-buffer-threshold'."
  (save-restriction
    (widen)
    (> (1- (position-bytes (point-max))) my-large-buffer-threshold)))

(defun my-prepare-large-buffer ()
  "Prevent global modes from enabling expensive extras in a large buffer."
  (when (my-large-buffer-p)
    (setq-local display-line-numbers-type nil
                company-idle-delay nil
                diff-hl-global-modes nil
                hl-todo-include-modes nil)))

;; Run before major-mode hooks and globalized minor modes inspect the buffer.
(add-hook 'change-major-mode-after-body-hook #'my-prepare-large-buffer)

(provide 'my-buffer-performance)
;;; buffer-performance.el ends here
