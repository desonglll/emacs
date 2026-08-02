;;; core-editing.el --- Editing behavior -*- lexical-binding: t; -*-

(delete-selection-mode 1)
(electric-pair-mode 1)
(global-auto-revert-mode 1)
(global-so-long-mode 1)

(setq auto-revert-verbose nil
      global-auto-revert-non-file-buffers t
      kill-do-not-save-duplicates t
      save-interprogram-paste-before-kill t
      scroll-conservatively 101
      mouse-wheel-progressive-speed nil)

;; Cleanup only trailing whitespace in programming and text buffers.
(add-hook 'before-save-hook
          (lambda ()
            (when (derived-mode-p 'prog-mode 'text-mode)
              (delete-trailing-whitespace))))

;; Handy built-in commands with conventional keys.
(global-set-key (kbd "C-c r") #'revert-buffer)
(global-set-key (kbd "C-c w") #'whitespace-mode)

(provide 'core-editing)
;;; core-editing.el ends here

