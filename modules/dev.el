;;; dev.el --- Development package configuration -*- lexical-binding: t; -*-

;;;; Environment and version control

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

;;;; Language server core

(my-use-package! lsp-mode
  :commands (lsp lsp-deferred)
  :init
  (setq lsp-keymap-prefix "C-c l")
  :custom
  (lsp-session-file (expand-file-name "lsp-session-v1" my-state-directory))
  ;; lsp-completion-mode still installs its CAPF; Corfu supplies the UI.
  (lsp-completion-provider :none)
  (lsp-diagnostics-provider :flymake)
  (lsp-enable-snippet nil)
  (lsp-headerline-breadcrumb-enable nil)
  (lsp-idle-delay 0.5)
  (lsp-keep-workspace-alive nil)
  (lsp-lens-enable nil)
  (lsp-log-io nil))

;;;; Language modes

(my-use-package! rust-mode
  :mode "\\.rs\\'")

(my-use-package! go-mode
  :mode "\\.go\\'")

(defconst my-lsp-language-clients
  '((c-mode)
    (c-ts-mode)
    (c++-mode)
    (c++-ts-mode)
    (go-mode)
    (go-ts-mode)
    (java-mode . lsp-java)
    (java-ts-mode . lsp-java)
    (python-mode . lsp-pyright)
    (python-ts-mode . lsp-pyright)
    (rust-mode)
    (rust-ts-mode))
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

;;;; Language-specific clients

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

;;;; Additional language tools

(my-use-package! just-mode
  :mode ("\\(?:^\\|/\\)[Jj]ustfile\\'" . just-mode))

(my-use-package! protobuf-mode
  :mode ("\\.proto\\'" . protobuf-mode))

(defun my-typst-start-lsp ()
  "Start Tinymist for the current Typst buffer when it is installed."
  (if (executable-find "tinymist")
      (lsp-deferred)
    (message "Tinymist is not installed; skipping Typst LSP")))

(my-use-package! typst-ts-mode
  :mode ("\\.typ\\'" . typst-ts-mode)
  :hook
  (typst-ts-mode . my-typst-start-lsp))

(provide 'my-dev)
;;; dev.el ends here
