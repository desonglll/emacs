;;; development.el --- Development workflow packages -*- lexical-binding: t; -*-

(my-use-package! exec-path-from-shell
  :demand t
  :custom
  (exec-path-from-shell-arguments '("-l"))
  :config
  (when (and (eq system-type 'darwin)
             (or (daemonp) (display-graphic-p)))
    (exec-path-from-shell-initialize)))

(my-use-package! envrc
  :commands envrc-global-mode
  :init
  ;; Initialize after other global modes so project environments load first.
  (add-hook 'after-init-hook #'envrc-global-mode 90)
  :bind
  (:map envrc-mode-map
        ("C-c E r" . envrc-reload)
        ("C-c E a" . envrc-allow)
        ("C-c E d" . envrc-deny)))

(my-use-package! verb
  :after org
  :demand t
  :config
  (keymap-set org-mode-map "C-c C-r" verb-command-map))

(my-use-package! magit
  :commands (magit-status magit-dispatch)
  :bind
  (("C-x g" . magit-status)
   ("C-x M-g" . magit-dispatch)))

(my-use-package! projectile
  :init
  (projectile-mode 1)
  :bind-keymap
  ("C-c p" . projectile-command-map))

(my-use-package! perspective
  :custom
  (persp-mode-prefix-key (kbd "C-c w"))
  :init
  (persp-mode 1)
  :config
  (load (expand-file-name "workspace-state.el" my-modules-directory) nil 'nomessage)
  (with-eval-after-load 'consult
    ;; Global buffers and recent files remain available through b/f narrowing.
    (consult-customize consult-source-buffer :hidden t :default nil)
    (consult-customize consult-source-recent-file :hidden t)
    (plist-put persp-consult-source :name "Workspace")
    (add-to-list 'consult-buffer-sources persp-consult-source)))

(my-use-package! gptel
  :config
  (setq gptel-model 'gpt-6
        gptel-stream t
        gptel-backend
        (gptel-make-openai "Sub2api"
          :host "sub2api.minutex.cn"
          :endpoint "/v1/chat/completions"
          :stream t
          :key (gptel-api-key-from-auth-source "sub2api.minutex.cn")
          :models '(gpt-6))
        )
  )
(setq gptel-autocomplete-debug nil)
(my-use-package! gptel-autocomplete
  :after gptel
  :bind
  (("C-<return>" . gptel-complete)
   :map gptel-autocomplete-completion-map
   ("C-M-<return>" . gptel-accept-completion)))

(provide 'my-plugins-development)
;;; development.el ends here
