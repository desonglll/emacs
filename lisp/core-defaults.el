;;; core-defaults.el --- Sensible built-in defaults -*- lexical-binding: t; -*-

(setq inhibit-startup-screen t
      inhibit-startup-message t
      initial-scratch-message nil
      ring-bell-function #'ignore
      use-short-answers t
      confirm-kill-emacs #'yes-or-no-p
      sentence-end-double-space nil
      require-final-newline t
      tab-always-indent 'complete
      read-process-output-max (* 1024 1024))

(set-language-environment "UTF-8")
(prefer-coding-system 'utf-8-unix)
(set-default-coding-systems 'utf-8-unix)

(setq-default indent-tabs-mode nil
              tab-width 4
              fill-column 80
              truncate-lines nil)

(provide 'core-defaults)
;;; core-defaults.el ends here
