;;; lsp.el --- Language server package configuration -*- lexical-binding: t; -*-

(load (expand-file-name "language-tools.el" my-modules-directory) nil 'nomessage)
(with-eval-after-load 'lsp-mode
  (load (expand-file-name "lsp-compat.el" my-modules-directory) nil 'nomessage))

;; Set these before lsp-mode loads its clients, including Volar's TS plugin.
(setq lsp-volar-location-for-typescript-plugin my-language-tools-directory
      lsp-toml-cache-path (expand-file-name "taplo/" my-state-directory))

(my-use-package! flymake
  :bind
  (("C-c d b" . flymake-show-buffer-diagnostics)
   ("C-c d p" . flymake-show-project-diagnostics)))

(my-use-package! lsp-mode
  :commands (lsp lsp-deferred)
  :init
  (setq lsp-keymap-prefix "C-c l")
  :custom
  (lsp-session-file (expand-file-name "lsp-session-v1" my-state-directory))
  ;; Company consumes lsp-mode's completion-at-point function via company-capf.
  (lsp-completion-provider :capf)
  ;; Do not retain empty results returned while a language server is indexing.
  (lsp-completion-no-cache t)
  (lsp-diagnostics-provider :flymake)
  (lsp-enable-snippet t)
  (lsp-headerline-breadcrumb-enable nil)
  (lsp-idle-delay 0.5)
  (lsp-keep-workspace-alive nil)
  (lsp-lens-enable nil)
  (lsp-log-io nil))

(defconst my-lsp-language-clients
  '((c-mode . lsp-clangd)
    (c-ts-mode . lsp-clangd)
    (c++-mode . lsp-clangd)
    (c++-ts-mode . lsp-clangd)
    (go-mode . lsp-go)
    (go-ts-mode . lsp-go)
    (java-mode . lsp-java)
    (java-ts-mode . lsp-java)
    (python-mode . lsp-pyright)
    (python-ts-mode . lsp-pyright)
    (rust-mode . lsp-rust)
    (rust-ts-mode . lsp-rust)
    (swift-mode . lsp-sourcekit)
    (swift-ts-mode . lsp-sourcekit)
    (js-mode . lsp-javascript)
    (js-ts-mode . lsp-javascript)
    (typescript-ts-mode . lsp-javascript)
    (typescript-mode . lsp-javascript)
    (tsx-ts-mode . lsp-javascript)
    (web-mode . lsp-volar)
    (yaml-mode . lsp-yaml)
    (yaml-ts-mode . lsp-yaml)
    (toml-mode . lsp-toml)
    (toml-ts-mode . lsp-toml)
    (sh-mode . lsp-bash)
    (bash-ts-mode . lsp-bash))
  "Major modes with automatic LSP and any external client feature.")

(defconst my-lsp-native-flymake-backends
  '((python-mode . python-flymake)
    (python-ts-mode . python-flymake)
    (rust-ts-mode . rust-ts-flymake))
  "Native Flymake backends superseded by LSP diagnostics.")

(defun my-start-language-lsp ()
  "Start the configured language server for the current major mode."
  (when-let* ((buffer-file-name)
              ((not (or (file-remote-p buffer-file-name) (my-large-buffer-p))))
              (client (alist-get major-mode my-lsp-language-clients))
              ((or (not (eq client 'lsp-volar))
                   (string-suffix-p ".vue" buffer-file-name)))
              (tools (alist-get client my-language-client-tools)))
    (let ((missing (seq-remove #'executable-find (plist-get tools :commands))))
      (if missing
          (message "LSP: missing %s; M-x my-language-tools-check for details"
                   (string-join missing ", "))
        (require 'lsp-mode)
        (require client)
        (unless (and (eq client 'lsp-bash) (not (lsp-bash-check-sh-shell)))
          (setq-local lsp-enabled-clients (plist-get tools :servers))
          (when-let ((backend
                      (alist-get major-mode my-lsp-native-flymake-backends)))
            (remove-hook 'flymake-diagnostic-functions backend t))
          (setq-local lsp-buffer-uri (lsp--path-to-uri (file-truename buffer-file-name)))
          (lsp-deferred))))))

;; YAML/TOML and mixed Vue buffers are not all derived from prog-mode.
;; After local variables also gives EditorConfig and envrc time to run.
(add-hook 'hack-local-variables-hook #'my-start-language-lsp 90)
(remove-hook 'prog-mode-hook #'my-start-language-lsp)

(defun my-jdtls-server-directory ()
  "Return the JDTLS directory containing its plugins, when installed."
  (when-let ((command (executable-find "jdtls")))
    (let* ((bin-directory (file-name-directory (file-truename command)))
           (install-directory
            (file-name-directory (directory-file-name bin-directory)))
           (libexec-directory
            (expand-file-name "libexec/" install-directory)))
      (cond
       ((file-directory-p (expand-file-name "plugins/" libexec-directory))
        libexec-directory)
       ((file-directory-p (expand-file-name "plugins/" install-directory))
        install-directory)))))

(defvar my-jdtls-external-server-directory nil
  "External JDTLS directory detected for the current Emacs session.")

(defun my-jdtls-native-workspace (command)
  "Keep the native launcher's data in the configured workspace directory."
  (if (and lsp-java-jdt-ls-prefer-native-command
           my-jdtls-external-server-directory)
      (progn
        (make-directory lsp-java-workspace-dir t)
        (append command (list "-data" lsp-java-workspace-dir)))
    command))

(my-use-package! lsp-java
  :after lsp-mode
  :init
  (setq lsp-java-workspace-dir
        (expand-file-name "lsp-java/workspace/" my-state-directory)
        lsp-java-workspace-cache-dir
        (expand-file-name "lsp-java/cache/" my-state-directory))
  (when-let ((server-directory (my-jdtls-server-directory)))
    (setq my-jdtls-external-server-directory server-directory
          lsp-java-server-install-dir server-directory
          lsp-java-jdt-ls-prefer-native-command t
          lsp-java-jdt-ls-command "jdtls"))
  :config
  (advice-add 'lsp-java--ls-command :filter-return #'my-jdtls-native-workspace)
  ;; Do not let lsp-java replace or delete a system-managed installation.
  (when-let ((client (and my-jdtls-external-server-directory
                          (gethash 'jdtls lsp-clients))))
    (aset client
          (cl-struct-slot-offset 'lsp--client 'download-server-fn)
          nil)))

(my-use-package! lsp-pyright
  :after lsp-mode
  :commands lsp-pyright-organize-imports
  :init
  (add-to-list 'lsp-disabled-clients 'ty-ls)
  :custom
  (lsp-pyright-python-executable-cmd "python3")
  (lsp-pyright-type-checking-mode "standard"))

(provide 'my-plugins-lsp)
;;; lsp.el ends here
