;;; early-init.el --- Early startup settings -*- lexical-binding: t; -*-

;; Keep package.el from activating packages before init.el is evaluated.
(setq package-enable-at-startup nil)

;; Avoid drawing UI elements that the main configuration disables anyway.
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(tooltip-mode -1)

(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Reduce startup work.  Restore a conservative value after initialization.
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024)
                  gc-cons-percentage 0.1)))

(provide 'early-init)
;;; early-init.el ends here
