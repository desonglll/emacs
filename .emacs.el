;; -*- lexical-binding: t; -*-

;;; package --- Summary

;;; Commentary:

;;; Code:

(when (eq system-type 'darwin)
  (setenv "PATH" (concat "/opt/homebrew/bin:/opt/homebrew/sbin:" (getenv "PATH")))
  (add-to-list 'exec-path "/opt/homebrew/bin")
  (setenv "LIBRARY_PATH"
          (concat (shell-command-to-string "brew --prefix libgccjit")
                  "/lib/gcc/13")))

(setq gc-cons-threshold most-positive-fixnum)
(setq straight-check-for-modifications '(check-on-save find-when-checking))
(defvar default-file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq file-name-handler-alist default-file-name-handler-alist)))

(setq custom-file (expand-file-name "~/.emacs.custom.el"))

;; LSP communication performance (default 4KB is a bottleneck for eglot)
(setq read-process-output-max (* 1024 1024))

(setq-default bidi-paragraph-direction 'left-to-right
              bidi-inhibit-bpa t)

(add-to-list 'custom-theme-load-path (expand-file-name "themes" user-emacs-directory))

(add-hook 'after-init-hook
          (lambda () (select-frame-set-input-focus (selected-frame))))

(savehist-mode 1)

(setq display-time-format "%Y-%m-%d %a %H:%M:%S")
(setq display-time-default-load-average nil)
(setq display-time-interval 1)

(display-time-mode 1)

(setq-default mode-line-format
              '("%e"
                " "
                (:eval (if (buffer-modified-p) "●" "○"))
                " | "
                (:propertize mode-line-buffer-identification face (:weight bold))
                " "
                (:propertize "%Z " face (:foreground "black"))
                " "
                "%l:%c"
                " "
                ;; (:propertize " " display (space :align-to (- right 15)))
                "["
                (:propertize mode-name face (:slant italic))
                "]"
                (:eval
                 (if (mode-line-window-selected-p)
                     (propertize mode-line-buffer-identification 'face '(:foreground "orange" :weight bold))
                   (propertize mode-line-buffer-identification 'face '(:foreground "grey40"))))
                " "
                vc-mode
                (:propertize " " display (space :align-to (- right 25)))
                display-time-string
                ))



;; keymaps

(global-set-key (kbd "C-c r") 'recentf-open-files)
(global-set-key (kbd "C-<tab>") 'switch-to-next-buffer)
(global-set-key (kbd "C-S-<tab>") 'switch-to-prev-buffer)
(global-set-key (kbd "C-,") 'duplicate-line)

(global-set-key (kbd "C-c c") 'compile)
(global-set-key (kbd "<f9>") 'compile)

;; plugins

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

(use-package gcmh
  :defer t
  :straight t
  :init (gcmh-mode 1))

(use-package benchmark-init
  :defer t
  :straight t
  :config
  (add-hook 'after-init-hook 'benchmark-init/deactivate))

(straight-use-package 'catppuccin-theme)

(use-package treesit-auto
  :straight t
  :custom
  (treesit-auto-install 'prompt)
  :config
  (global-treesit-auto-mode))

(use-package expand-region
  :defer t
  :straight t
  :bind
  ("C-=" . er/expand-region)
  ("C-+" . er/contract-region))

(use-package magit
  :defer t
  :straight t
  :bind
  ("M-<f1>" . magit)
  )

(use-package corfu
  :defer t
  :straight t
  :init
  (global-corfu-mode)
  :custom
  (corfu-auto nil)
  (corfu-cycle t)
  :config
  (corfu-popupinfo-mode 1)
  (corfu-history-mode 1)
  (add-to-list 'savehist-additional-variables 'corfu-history)
  (require 'corfu-info)

  :bind (:map corfu-map
        ("TAB" . corfu-next)
        ([tab] . corfu-next)
        ("S-TAB" . corfu-previous)
        ([backtab] . corfu-previous)
        ("M-n" . corfu-popupinfo-scroll-up)
        ("M-p" . corfu-popupinfo-scroll-down))
  )

(use-package orderless
  :defer t
  :straight t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package cape
  :defer t
  :straight t
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-elisp-block))

(use-package avy
  :straight t
  :config
  ;; (global-set-key (kbd "C-:") 'avy-goto-char)
  (global-set-key (kbd "C-:") 'avy-goto-char-2)
  (global-set-key (kbd "M-g g") 'avy-goto-line)
  (global-set-key (kbd "M-g w") 'avy-goto-word-1)
  (global-set-key (kbd "C-M-:") 'avy-goto-word-0)
)

(use-package vertico
  :defer t
  :straight t
  :init
  (vertico-mode 1)
  :config
  (vertico-indexed-mode 1)
  (vertico-multiform-mode 1)
  (setq vertico-cycle t)
  (setq vertico-preselect-input t)
  :bind (:map vertico-map
        ("RET" . vertico-directory-enter)
        ("DEL" . vertico-directory-delete-char)
        ("M-RET" . vertico-directory-exit-input)
        ))

(use-package consult
  :defer t
  :straight t
  :bind(("C-c M-x" . consult-mode-command)
        ("C-c h" . consult-history)
        ("C-c k" . consult-kmacro)
        ("C-c m" . consult-man)
        ("C-c i" . consult-info)
        ("C-c r" . consult-recent-file)
        ([remap Info-search] . consult-info)
        ;; C-x bindings in `ctl-x-map'
        ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
        ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
        ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
        ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
        ("C-x t b" . consult-buffer-other-tab)    ;; orig. switch-to-buffer-other-tab
        ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
        ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
        ;; Custom M-# bindings for fast register access
        ("M-#" . consult-register-load)
        ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
        ("C-M-#" . consult-register)
        ;; Other custom bindings
        ("M-y" . consult-yank-pop)                ;; orig. yank-pop
        ;; M-g bindings in `goto-map'
        ("M-g e" . consult-compile-error)
        ("M-g r" . consult-grep-match)
        ("M-g f" . consult-flycheck)               ;; Alternative: consult-flycheck
        ("M-g g" . consult-goto-line)             ;; orig. goto-line
        ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
        ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
        ("M-g m" . consult-mark)
        ("M-g k" . consult-global-mark)
        ("M-g i" . consult-imenu)
        ("M-g I" . consult-imenu-multi)
        ;; M-s bindings in `search-map'
        ("M-s d" . consult-fd)                  ;; Alternative: consult-fd
        ("M-s c" . consult-locate)
        ("M-s g" . consult-grep)
        ("M-s G" . consult-git-grep)
        ("M-s r" . consult-ripgrep)
        ("M-s l" . consult-line)
        ("M-s L" . consult-line-multi)
        ("M-s k" . consult-keep-lines)
        ("M-s u" . consult-focus-lines)
        ;; Isearch integration
        ("M-s e" . consult-isearch-history)
        :map isearch-mode-map
        ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
        ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
        ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
        ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
        ;; Minibuffer history
        :map minibuffer-local-map
        ("M-s" . consult-history)                 ;; orig. next-matching-history-element
        ("M-r" . consult-history))                ;; orig. previous-matching-history-element
  :config
  (setq consult-narrow-key "<")
  (setq consult-fd-args '("fd" "--color=never" "--hidden" "--full-path"))

  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep consult-man
   consult-bookmark consult-recent-file consult-xref
   consult-source-bookmark consult-source-file-register
   consult-source-recent-file consult-source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))
  )

(use-package consult-dir
  :defer t
  :straight t
  :bind (("C-x C-d" . consult-dir)
         :map vertico-map
         ("C-x C-d" . consult-dir)
         ("C-x C-j" . consult-dir-jump-file)))

(use-package consult-eglot
  :defer t
  :straight t
  :bind (:map eglot-mode-map ("M-." . consult-eglot-symbols)))

(use-package marginalia
  :defer t
  :straight t
  :init
  (marginalia-mode 1))

(use-package embark
  :defer t
  :straight t
  :bind (("C-." . embark-act)
         ("C-;" . embark-dwim)))

(use-package embark-consult
  :defer t
  :straight t
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))

(use-package which-key
  :defer t
  :straight t
  :init
  (which-key-mode))

(use-package exec-path-from-shell
  :straight t
  :config
  (when (memq window-system '(mac ns))
    (setq exec-path-from-shell-arguments '("-l"))
    (setq exec-path-from-shell-variables '("PATH" "MANPATH" "ANTHROPIC_API_KEY" "ANTHROPIC_BASE_URL"))
    (exec-path-from-shell-initialize)))

;; (use-package dired+
;;   :straight t)

(use-package projectile
  :straight t
  :defer t
  :init
  (projectile-mode +1)
  :bind-keymap ("C-c C-p" . projectile-command-map))

(use-package multiple-cursors
  :straight t
  :defer t
  :init
  :bind (
         ("C-S-c C-S-c" . mc/edit-lines)
         ("C->"         . mc/mark-next-like-this)
         ("C-<"         . mc/mark-previous-like-this)
         ("C-c C-<"     . mc/mark-all-like-this)
         ))

(use-package rust-mode
  :straight t
  :defer t
  )

(use-package go-mode
  :straight t
  :defer t
  )

(use-package markdown-mode
  :straight t
  :defer t
  :init
  (setq markdown-command "pandoc")
  )

;; (use-package flycheck
;;   :defer t
;;   :straight t
;;   :config
;;   (add-hook 'rust-mode-hook
;;             (lambda ()
;;               (setq-local flycheck-checker 'rust-clippy)
;;               ))
;;   (add-hook 'after-init-hook #'global-flycheck-mode)
;;   )

(use-package vterm
  :defer t
  :straight t)

(use-package gptel
  :defer t
  :straight t)

(defun gptel-api-key-from-environment (&optional var)
  (lambda ()
    (getenv (or var                     ;provided key
                (thread-first           ;or fall back to <TYPE>_API_KEY
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
  :models '("Pro/zai-org/GLM-5.1")))

(straight-use-package
 '(gptel-autocomplete :type git :host github :repo "JDNdeveloper/gptel-autocomplete"))

(require 'gptel-autocomplete)

(keymap-set gptel-autocomplete-completion-map "C-e" #'gptel-accept-completion)
(setq gptel-autocomplete-idle-delay 0.3)


(use-package claude-code-ide
  :defer t
  :straight (:type git :host github :repo "manzaltu/claude-code-ide.el")
  :bind ("C-c C-'" . claude-code-ide-menu) ; Set your favorite keybinding
  :config
  (claude-code-ide-emacs-tools-setup))

(add-hook 'python-ts-mode-hook 'eglot-ensure)
(add-hook 'go-mode-hook 'eglot-ensure)
(add-hook 'rust-mode-hook 'eglot-ensure)

(use-package eglot
  :defer t
  :ensure nil
  :config
  (setq eglot-send-changes-idle-time 0.5))

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '(python-ts-mode . ("ty" "server"))
               '((ruby-mode ruby-ts-mode) . ("ruby-lsp")))

  (setq eglot-events-buffer-size 0
        eglot-autoreconnect 60))

(when (file-exists-p custom-file)
  (load custom-file))

(load-theme 'catppuccin :no-confirm)

;; (add-to-list 'default-frame-alist '(undecorated . t))

(provide 'init)

;;; init.el ends here
