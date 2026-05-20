;; -*- lexical-binding: t; -*-
;; LLM chat client — https://github.com/karthink/gptel
(use-package gptel
  :straight t
  :defer t
  :config
  (defun gptel-api-key-from-environment (&optional var)
    (lambda ()
      (getenv (or var
                  (thread-first
                    (type-of gptel-backend)
                    (symbol-name)
                    (substring 6)
                    (upcase)
                    (concat "_API_KEY"))))))

  (setq gptel-api-key (gptel-api-key-from-environment "ANTHROPIC_API_KEY"))
  (setq gptel-log-level 'debug)
  (setq gptel-backend (gptel-make-openai "SiliconFlow-OpenAI"
                          :host "api.siliconflow.cn"
                          :endpoint "/v1/chat/completions"
                          :key gptel-api-key
                          :stream t
                          :request-params '(:thinking (:type "disabled"))
                          :models '("Pro/zai-org/GLM-5.1"))))

;; AI inline autocomplete — https://github.com/JDNdeveloper/gptel-autocomplete
(use-package gptel-autocomplete
  :straight (gptel-autocomplete :type git :host github
             :repo "JDNdeveloper/gptel-autocomplete")
  :defer t
  :after gptel
  :config
  (keymap-set gptel-autocomplete-completion-map "C-e" #'gptel-accept-completion)
  (setq gptel-autocomplete-idle-delay 0.3))

;; Claude Code IDE integration — https://github.com/manzaltu/claude-code-ide.el
(use-package claude-code-ide
  :straight (:type git :host github :repo "manzaltu/claude-code-ide.el")
  :defer t
  :bind ("C-c C-'" . claude-code-ide-menu)
  :config (claude-code-ide-emacs-tools-setup))

(provide 'ai)
