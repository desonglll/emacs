;;; completion-buffer.el --- In-buffer completion -*- lexical-binding: t; -*-

(use-package corfu
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.15)
  (corfu-auto-prefix 2)
  (corfu-cycle t)
  (corfu-preselect 'prompt)
  (corfu-preview-current nil)
  :init
  (global-corfu-mode 1)
  :config
  (corfu-popupinfo-mode 1))

(use-package cape
  :bind
  (("M-/" . cape-dabbrev)
   ("C-c p f" . cape-file)
   ("C-c p k" . cape-keyword))
  :init
  (add-hook 'completion-at-point-functions #'cape-dabbrev 90)
  (add-hook 'completion-at-point-functions #'cape-file 100))

(provide 'completion-buffer)
;;; completion-buffer.el ends here
