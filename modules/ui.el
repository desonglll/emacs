;; -*- lexical-binding: t; -*-
;; Catppuccin color theme — https://github.com/catppuccin/emacs
(straight-use-package 'catppuccin-theme)
(add-to-list 'custom-theme-load-path (expand-file-name "themes" user-emacs-directory))

(setq display-time-format "%Y-%m-%d %a %H:%M:%S"
      display-time-default-load-average nil
      display-time-interval 1)
(display-time-mode 1)

(setq-default mode-line-format
              '("%e" " "
                (:eval (if (buffer-modified-p) "●" "○"))
                " | "
                (:propertize mode-line-buffer-identification face (:weight bold))
                " "
                (:propertize "%Z " face (:foreground "black"))
                " " "%l:%c" " "
                "[" (:propertize mode-name face (:slant italic)) "]"
                (:eval
                 (if (mode-line-window-selected-p)
                     (propertize mode-line-buffer-identification 'face '(:foreground "orange" :weight bold))
                   (propertize mode-line-buffer-identification 'face '(:foreground "grey40"))))
                " " vc-mode
                (:propertize " " display (space :align-to (- right 25)))
                display-time-string))

(add-hook 'after-init-hook
          (lambda () (select-frame-set-input-focus (selected-frame))))

(load-theme 'catppuccin :no-confirm)

(use-package indent-bars
  :straight t
  ;; :hook (prog-mode . indent-bars-mode)
  :config
  (setq indent-bars-color '(highlight :face-bg t :blend 0.15)
        indent-bars-pattern "."
        indent-bars-width-offset 1))

(provide 'ui)
