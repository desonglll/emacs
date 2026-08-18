;;; lsp.el --- Language server package configuration -*- lexical-binding: t; -*-

(my-use-package! lsp-mode
  :commands (lsp lsp-deferred)
  :init
  (setq lsp-keymap-prefix "C-c l")
  :custom
  (lsp-session-file (expand-file-name "lsp-session-v1" my-state-directory))
  ;; lsp-completion-mode still installs its CAPF; Corfu supplies the UI.
  (lsp-completion-provider :none)
  (lsp-diagnostics-provider :flymake)
  (lsp-enable-snippet t)
  (lsp-headerline-breadcrumb-enable nil)
  (lsp-idle-delay 0.5)
  (lsp-keep-workspace-alive nil)
  (lsp-lens-enable nil)
  (lsp-log-io nil))

(defconst my-lsp-language-clients
  '((c-mode)
    (c-ts-mode)
    (c++-mode)
    (c++-ts-mode)
    (go-mode . lsp-go)
    (go-ts-mode . lsp-go)
    (java-mode . lsp-java)
    (java-ts-mode . lsp-java)
    (python-mode . lsp-pyright)
    (python-ts-mode . lsp-pyright)
    (rust-mode . lsp-rust)
    (rust-ts-mode . lsp-rust)
    (swift-mode . lsp-sourcekit)
    (swift-ts-mode . lsp-sourcekit))
  "Major modes with automatic LSP and any external client feature.")

(defconst my-lsp-native-flymake-backends
  '((python-mode . python-flymake)
    (python-ts-mode . python-flymake)
    (rust-ts-mode . rust-ts-flymake))
  "Native Flymake backends superseded by LSP diagnostics.")

(defun my-start-language-lsp ()
  "Start the configured language server for the current major mode."
  (when-let ((client (assq major-mode my-lsp-language-clients)))
    (when-let ((backend
                (alist-get major-mode my-lsp-native-flymake-backends)))
      (remove-hook 'flymake-diagnostic-functions backend t))
    (when (cdr client)
      (require (cdr client)))
    (lsp-deferred)))

(add-hook 'prog-mode-hook #'my-start-language-lsp)

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
          lsp-java-jdt-ls-prefer-native-command nil))
  :config
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
