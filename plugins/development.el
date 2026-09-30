;;; development.el --- Development workflow packages -*- lexical-binding: t; -*-

(my-use-package! exec-path-from-shell
  :demand t
  :custom
  (exec-path-from-shell-arguments '("-l"))
  :config
  (when (and (eq system-type 'darwin)
             (or (daemonp) (display-graphic-p)))
    (exec-path-from-shell-initialize)))

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
  ;; :bind
  ;; (("C-x C-b" . persp-list-buffers)
  ;;  ("C-c w s" . persp-switch)
  ;;  ("C-c w n" . persp-switch)
  ;;  ("C-c w k" . persp-kill))
  :custom
  (persp-mode-prefix-key (kbd "C-c w"))
  :init
  (persp-mode))

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
(setq gptel-autocomplete-debug t)
(my-use-package! gptel-autocomplete
  :after gptel
  :bind
  (("C-<return>" . gptel-complete)
   :map gptel-autocomplete-completion-map
   ("C-M-<return>" . gptel-accept-completion)))

(provide 'my-plugins-development)
;;; development.el ends here
