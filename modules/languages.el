;;; languages.el --- Language package configuration -*- lexical-binding: t; -*-

;;;; Chinese input

(my-use-package! pyim
  :commands pyim-convert-string-at-point
  :init
  (setq default-input-method "pyim")
  :config
  (pyim-default-scheme 'quanpin))

(my-use-package! pyim-basedict
  :after pyim
  :config
  (pyim-basedict-enable))

;;;; Language modes

(my-use-package! rust-mode
  :mode "\\.rs\\'")

(my-use-package! go-mode
  :mode "\\.go\\'")

;;;; Language servers

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

(defun my-start-language-lsp ()
  "Start the configured language server for the current major mode."
  (when-let ((client (assq major-mode my-lsp-language-clients)))
    (when (memq major-mode '(python-mode python-ts-mode))
      (remove-hook 'flymake-diagnostic-functions #'python-flymake t))
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

(provide 'my-languages)
;;; languages.el ends here
