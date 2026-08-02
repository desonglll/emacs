;;; core-packages.el --- straight.el package management -*- lexical-binding: t; -*-

(setq straight-recipe-overrides nil)

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Let use-package install packages through straight by default.
(straight-use-package 'use-package)
(require 'use-package)
(straight-override-recipe
 '(xr :type git :host github :repo "mattiase/xr"))
(setq straight-use-package-by-default t
      use-package-always-defer t)

(provide 'core-packages)
;;; core-packages.el ends here
