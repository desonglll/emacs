;;; window-layout.el --- Predictable auxiliary panels -*- lexical-binding: t; -*-

(defun my-auxiliary-buffer-p (buffer _action)
  "Match help, diagnostics, search results, and compilation BUFFER."
  (when-let ((buffer (get-buffer buffer)))
    (with-current-buffer buffer
      (derived-mode-p 'help-mode 'helpful-mode 'compilation-mode
                      'flymake-diagnostics-buffer-mode
                      'flymake-project-diagnostics-mode))))

;; Share the terminal slot: replacing a panel preserves its buffer/process.
;; `quit-window' uses Emacs's quit-restore information to restore the caller.
(add-to-list 'display-buffer-alist
             `(my-auxiliary-buffer-p
               (display-buffer-reuse-window display-buffer-in-side-window)
               (side . bottom) (slot . 0)
               (window-height . ,my-terminal-panel-height)))

(provide 'my-window-layout)
;;; window-layout.el ends here
