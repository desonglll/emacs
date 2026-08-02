;;; config-packages.el --- Package management -*- lexical-binding: t; -*-

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

(straight-use-package 'use-package)
(require 'use-package)

;; Work around a case-sensitive filename collision in the ELPA mirror.
(straight-override-recipe
 '(xr :type git :host github :repo "mattiase/xr"))

(setq straight-use-package-by-default t
      use-package-always-defer t)

(defmacro my-use-git-package (name host repository &rest arguments)
  "Configure NAME from HOST/REPOSITORY with use-package ARGUMENTS."
  (declare (indent 3))
  `(use-package ,name
     :straight (,name :type git :host ,host :repo ,repository)
     ,@arguments))

(provide 'config-packages)
;;; config-packages.el ends here
