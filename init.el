;;; init.el --- Personal Emacs configuration -*- lexical-binding: t; -*-

(defconst my-config-directory
  (file-name-as-directory user-emacs-directory)
  "Root directory of this Emacs configuration.")

(defconst my-state-directory
  (expand-file-name "var/" my-config-directory)
  "Directory for generated state and cache files.")

(make-directory my-state-directory t)
(add-to-list 'load-path (expand-file-name "lisp/" my-config-directory))

;; Keep Customize output separate from hand-written configuration.
(setq custom-file (expand-file-name "custom.el" my-state-directory))
(when (file-exists-p custom-file)
  (load custom-file nil 'nomessage))

(require 'config-packages)
(require 'config-core)
(require 'config-completion)
(require 'config-tools)
(require 'config-languages)
(require 'config-keybindings)

;; Put personal, machine-specific settings in local.el.  It is gitignored.
(let ((local-file (expand-file-name "local.el" my-config-directory)))
  (when (file-exists-p local-file)
    (load local-file nil 'nomessage)))

;;; init.el ends here
