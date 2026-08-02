;;; platform-macos.el --- macOS integration -*- lexical-binding: t; -*-

(when (eq system-type 'darwin)
  ;; Command supplies Super bindings; Option supplies conventional Meta keys.
  (setq mac-command-modifier 'super
        mac-option-modifier 'meta
        ns-command-modifier 'super
        ns-alternate-modifier 'meta
        ns-option-modifier 'meta))

(use-package exec-path-from-shell
  :demand t
  :custom
  (exec-path-from-shell-arguments '("-l"))
  :config
  (when (and (eq system-type 'darwin)
             (or (daemonp) (display-graphic-p)))
    (exec-path-from-shell-initialize)))

(defun my-focus-initial-frame ()
  "Give the initial graphical frame keyboard focus."
  (when (display-graphic-p)
    (select-frame-set-input-focus (selected-frame))))

(add-hook 'emacs-startup-hook #'my-focus-initial-frame)

(provide 'platform-macos)
;;; platform-macos.el ends here
