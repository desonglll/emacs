;;; core-ui.el --- Minimal built-in interface -*- lexical-binding: t; -*-

(setq frame-title-format '("%b - Emacs")
      icon-title-format frame-title-format
      visible-bell nil
      cursor-in-non-selected-windows nil)

(column-number-mode 1)
(global-display-line-numbers-mode 1)
(global-hl-line-mode 1)
(show-paren-mode 1)

;; Line numbers add noise in buffers where they do not describe source text.
(dolist (hook '(eshell-mode-hook
                shell-mode-hook
                term-mode-hook
                vterm-mode-hook
                help-mode-hook
                special-mode-hook))
  (add-hook hook (lambda () (display-line-numbers-mode -1))))

(provide 'core-ui)
;;; core-ui.el ends here
