;;; init.el --- Personal Emacs configuration -*- lexical-binding: t; -*-

(defconst my-config-directory
  (file-name-as-directory
   (file-name-directory
    (file-truename (or load-file-name user-init-file))))
  "Root directory of this Emacs configuration.")

(defconst my-data-directory
  my-config-directory
  "Root directory for generated Emacs data and downloaded packages.")

(defconst my-state-directory
  (expand-file-name "var/" my-data-directory)
  "Directory for generated state and cache files.")

(defconst my-modules-directory
  (expand-file-name "modules/" my-config-directory)
  "Directory containing personal configuration modules.")

(defconst my-plugins-directory
  (expand-file-name "plugins/" my-config-directory)
  "Directory containing third-party package configuration.")

(make-directory my-state-directory t)

;; Keep Customize output separate from hand-written configuration.
(setq custom-file (expand-file-name "custom.el" my-state-directory))
(when (file-exists-p custom-file)
  (load custom-file nil 'nomessage))

;; Install packages before loading native and third-party configuration.
(load (expand-file-name "packages.el" my-config-directory) nil 'nomessage)
(load (expand-file-name "config.el" my-config-directory) nil 'nomessage)

(dolist (plugin-file
         (directory-files my-plugins-directory t "\\`[^.].*\\.el\\'"))
  (when (file-regular-p plugin-file)
    (load plugin-file nil 'nomessage)))

(dolist (module '("rc.el" "keymaps.el"))
  (load (expand-file-name module my-modules-directory) nil 'nomessage))

;; Put personal, machine-specific settings in local.el.  It is gitignored.
(let ((local-file (expand-file-name "local.el" my-config-directory)))
  (when (file-exists-p local-file)
    (load local-file nil 'nomessage)))

;;; init.el ends here
(put 'upcase-region 'disabled nil)
