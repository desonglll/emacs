;; -*- lexical-binding: t; -*-

(setq elixir-lsp-path "~/elixir-ls-v0.30.0/")

;; Lazy env vars from shell — https://github.com/purcell/exec-path-from-shell
(use-package exec-path-from-shell
  :straight t
  :defer 1
  :config
  (when (memq window-system '(mac ns))
    (setq exec-path-from-shell-arguments '("-l"))
    (setq exec-path-from-shell-variables
          '("PATH"
            "/opt/homebrew/bin"
            "MANPATH"
            "ANTHROPIC_API_KEY"
            "ANTHROPIC_BASE_URL"
            ))
    (exec-path-from-shell-initialize)))

;; Auto-install tree-sitter grammars
(use-package treesit-auto
  :straight t
  :defer t
  :custom (treesit-auto-install 'prompt))

;; LSP client (built-in since 29) — https://github.com/joaotavora/eglot
(use-package eglot
  :straight t
  :defer t
  ;; :hook ((rust-ts-mode . eglot-ensure)
  ;;        (python-ts-mode . eglot-ensure)
  ;;        (go-mode . eglot-ensure)
  ;;        (ruby-ts-mode . eglot-ensure)
  ;;        (c-ts-mode . eglot-ensure)
  ;;        (c++-ts-mode . eglot-ensure))
  :custom
  (eglot-workspace-configuration
   '(:rust-analyzer
     (:check (:command "clippy"))))
  :config
  (setq eglot-send-changes-idle-time 0.5
        eglot-events-buffer-size 0
        eglot-autoreconnect 60)
  (add-to-list 'eglot-server-programs '(python-ts-mode . ("ty" "server")))
  (add-to-list 'eglot-server-programs '((ruby-mode ruby-ts-mode) . ("ruby-lsp")))
  (add-to-list 'eglot-server-programs `((elixir-mode elixir-ts-mode) . (,(expand-file-name "language_server.sh" elixir-lsp-path))))
  )

(use-package jinx
  :straight t
  :hook (text-mode . jinx-mode)
  :bind (:map jinx-mode-map
              ("M-$" . jinx-correct)))

;; Git diff indicators in fringe — https://github.com/dgutov/diff-hl
(use-package diff-hl
  :straight t
  :hook ((prog-mode . diff-hl-mode)
         (vc-dir-mode . diff-hl-dir-mode)
         (dired-mode . diff-hl-dired-mode))
  :config
  (diff-hl-margin-mode 1)
  (setq diff-hl-disable-on-remote t))

;; Async code formatter on save — https://github.com/raxod502/apheleia
(use-package apheleia
  :straight t
  :hook (prog-mode . apheleia-mode))

;; Colorful nested delimiters — https://github.com/Fanael/rainbow-delimiters
(use-package rainbow-delimiters
  :straight t
  :hook (prog-mode . rainbow-delimiters-mode))

;; Highlight TODO/FIXME/HACK in comments — https://github.com/tarsius/hl-todo
(use-package hl-todo
  :straight t
  :hook (prog-mode . hl-todo-mode))

;; Git porcelain — https://github.com/magit/magit
(use-package magit
  :straight t
  :defer t
  :bind ("M-<f1>" . magit))

;; Git 平台集成 — 在 magit 里直接操作 GitHub/GitLab Issues 和 PR
(use-package forge
  :straight t
  :after magit
  :defer t)

;; Project management — https://github.com/bbatsov/projectile
(use-package projectile
  :straight t
  :defer t
  :init
  (projectile-mode +1)
  (setq projectile-auto-discover nil)
  :bind-keymap ("C-c C-p" . projectile-command-map))

;; https://github.com/nex3/perspective-el
(use-package perspective
  :bind
  ("C-x C-b" . persp-list-buffers)         ; or use a nicer switcher, see below
  :custom
  (persp-mode-prefix-key (kbd "C-c M-p"))  ; pick your own prefix key here
  :straight t
  :defer t
  :init
  (persp-mode)
  :config
  (setq persp-sort 'created)
  (add-to-list 'consult-buffer-sources 'persp-consult-source)
  )

;; Rust — https://github.com/rust-lang/rust-mode
(use-package rust-mode :straight t :defer t)

;; Go — https://github.com/dominikh/go-mode.el
(use-package go-mode :straight t :defer t)

;; Markdown — https://github.com/jrblevin/markdown-mode
(use-package markdown-mode
  :straight t
  :defer t
  :init (setq markdown-command "pandoc"))

;; Terminal emulator — https://github.com/akermu/emacs-libvterm
(use-package vterm :straight t :defer t)

(use-package diredfl
  :straight t
  :after dired
  :hook (dired-mode . diredfl-mode))

(use-package ace-window
  :straight t
  :defer t
  :bind ("M-o" . ace-window))

(use-package elixir-mode
  :straight t
  :defer t
  :config
  (add-to-list 'auto-mode-alist '("\\.elixir2\\'" . elixir-mode))
  )

(use-package yaml-mode
  :straight t
  :defer t)

(use-package nix-mode
  :straight t
  :defer t)
(add-to-list 'auto-mode-alist '("\\.nix\\'" . nix-mode))

;; for erlang
;; brew install erlang
;; (setq load-path (cons  "/opt/homebrew/opt/erlang/lib/erlang/lib/tools-4.1.4/emacs"
;;                        load-path))
;; (setq erlang-root-dir "/opt/homebrew/opt/erlang")
;; (setq exec-path (cons "/opt/homebrew/opt/erlang/bin" exec-path))
;; (require 'erlang-start)

(provide 'dev)
