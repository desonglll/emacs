;;; plugins.el --- Central third-party package configuration -*- lexical-binding: t; -*-

;;;; User interface

(my-use-package! gruber-darker-theme
  :demand t
  :config
  (mapc #'disable-theme custom-enabled-themes)
  (load-theme 'gruber-darker t))

(my-use-package! dirvish
  :commands dirvish)

(my-use-package! imenu-list
  :commands imenu-list)

(my-use-package! treemacs
  :commands treemacs)

;;;; Completion

;;; Minibuffer

(defun my-recentf ()
  "Open a recent file while preserving recentf's MRU order."
  (interactive)
  (let ((vertico-sort-override-function #'identity))
    (call-interactively #'recentf)))

(my-use-package! vertico
  :init
  (vertico-mode 1)
  :config
  (require 'vertico-directory)
  :bind
  (:map vertico-map
        ("RET" . vertico-directory-enter)
        ("DEL" . vertico-directory-delete-char)
        ("M-DEL" . vertico-directory-delete-word)))

(my-use-package! orderless
  :demand t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides
   '((file (styles partial-completion)))))

(my-use-package! marginalia
  :init
  (marginalia-mode 1))

(my-use-package! consult
  :bind
  (("C-s" . consult-line)
   ("C-x b" . consult-buffer)
   ("M-y" . consult-yank-pop)
   ("M-g g" . consult-goto-line)
   ("M-g i" . consult-imenu))
  :config
  (consult-customize
   consult-ripgrep consult-git-grep consult-grep consult-man
   consult-bookmark consult-recent-file consult-xref
   consult-source-bookmark consult-source-file-register
   consult-source-recent-file consult-source-project-recent-file
   :preview-key '(:debounce 0.4 any)))

(my-use-package! embark
  :bind
  (("C-." . embark-act)
   ("C-;" . embark-dwim)
   ("C-h B" . embark-bindings))
  :init
  (setq prefix-help-command #'embark-prefix-help-command))

(my-use-package! embark-consult
  :after (embark consult)
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

;;; In-buffer

;; (my-use-package! corfu
;;   :custom
;;   (corfu-auto t)
;;   (corfu-auto-delay 0.15)
;;   (corfu-auto-prefix 2)
;;   (corfu-cycle t)
;;   (corfu-preselect 'prompt)
;;   (corfu-preview-current nil)
;;   :init
;;   (global-corfu-mode 1)
;;   :config
;;   (corfu-popupinfo-mode 1))

(my-use-package! company
  :hook (after-init . global-company-mode)
  :bind
  (("M-<tab>" . #'company-complete))
  :config
  (setq company-idle-delay 0.01
        company-minimum-prefix-length 2
        company-selection-wrap-around t
        company-tooltip-limit 12)
  (with-eval-after-load 'company
    (set-face-attribute 'company-tooltip-selection nil
                        :background "#005f87"
                        :foreground "white"
                        :weight 'bold)))

(my-use-package! cape
  :bind
  (("M-/" . cape-dabbrev)
   ("C-c p f" . cape-file)
   ("C-c p k" . cape-keyword))
  :init
  (add-hook 'completion-at-point-functions #'cape-dabbrev 90)
  (add-hook 'completion-at-point-functions #'cape-file 100))

;;;; Editing

;;; Snippets

(my-use-package! yasnippet
  :demand t
  :config
  (yas-global-mode 1))

;;; Navigation and buffers

(my-use-package! ace-window
  :commands ace-window)

(my-use-package! avy
  :commands avy-goto-char-2)

;;; Input and text

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

(my-use-package! translate
  :commands (translate-trans translate-argo))

;;;; Development

;;; Environment and version control

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

;;; Language server core

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

;;; Language modes

(my-use-package! rust-mode
  :mode "\\.rs\\'")

(my-use-package! go-mode
  :mode "\\.go\\'")

(my-use-package! swift-mode
  :mode "\\.swift\\(?:interface\\)?\\'")

(my-use-package! swift-ts-mode
  :commands swift-ts-mode)

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

;;; Language-specific clients

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

;;; Additional language tools

(my-use-package! just-mode
  :mode ("\\(?:^\\|/\\)[Jj]ustfile\\'" . just-mode))

(my-use-package! protobuf-mode
  :mode ("\\.proto\\'" . protobuf-mode))

(defun format/lsp-region-or-buffer ()
  "Format the active region or current buffer through LSP."
  (interactive)
  (if (use-region-p)
      (lsp-format-region (region-beginning) (region-end))
    (lsp-format-buffer)))

(defun my-typst-start-lsp ()
  "Start Tinymist for the current Typst buffer when it is installed."
  (if (executable-find "tinymist")
      (lsp-deferred)
    (message "Tinymist is not installed; skipping Typst LSP")))

(my-use-package! typst-ts-mode
  :mode ("\\.typ\\'" . typst-ts-mode)
  :bind
  (:map typst-ts-mode-map
        ("C-M-\\" . format/lsp-region-or-buffer))
  :hook
  (typst-ts-mode . my-typst-start-lsp))

(defun format/register-mode (language mode)
  "Register MODE as LANGUAGE in language-id's mode table."
  (if-let ((definition (assoc language language-id--definitions)))
      (unless (memq mode (cdr definition))
        (setcdr definition (cons mode (cdr definition))))
    (push (list language mode) language-id--definitions)))

(defun format/formatter-available-p (formatter)
  "Return non-nil when FORMATTER can run in the current buffer."
  (let* ((normalized (format-all--normalize-formatter formatter))
         (name (car normalized)))
    (and (gethash name format-all--format-table)
         (condition-case nil
             (progn
               (format-all--command-args normalized)
               t)
           (format-all-executable-not-found nil)))))

(defun format/enable-on-save ()
  "Enable format-on-save when this buffer has an available formatter."
  (require 'format-all)
  (when-let* ((language (format-all--language-id-buffer))
              (chain (format-all--get-chain language))
              ((cl-every #'format/formatter-available-p chain)))
    (format-all-mode 1)))

(my-use-package! format-all
  :diminish format-all-mode
  :bind
  ("C-M-\\" . format-all-region-or-buffer)
  :hook
  (prog-mode . format/enable-on-save)
  (text-mode . format/enable-on-save)
  :init
  (add-to-list 'auto-mode-alist '("\\.jsonc\\'" . js-json-mode))
  (with-eval-after-load 'language-id
    (format/register-mode "JSON" 'js-json-mode)
    (format/register-mode "Swift" 'swift-ts-mode)
    (format/register-mode "Typst" 'typst-ts-mode))
  :config
  (setq-default format-all-formatters
                '(("C" (clang-format "--style=LLVM"))
                  ("C++" (clang-format "--style=LLVM"))
                  ("CSS" prettier)
                  ("Dockerfile" dockfmt)
                  ("Emacs Lisp" emacs-lisp)
                  ("Go" gofmt)
                  ("HTML" prettier)
                  ("Java" google-java-format)
                  ("JavaScript" prettier)
                  ("JSON" prettier)
                  ("JSON5" prettier)
                  ("JSX" prettier)
                  ("Markdown" prettier)
                  ("Python" (black "--line-length" "88"))
                  ("Rust" rustfmt)
                  ("SCSS" prettier)
                  ("Shell" (shfmt "-i" "2"))
                  ("Swift" swiftformat)
                  ("TSX" prettier)
                  ("TypeScript" prettier)
                  ("Vue" prettier)
                  ("XML" html-tidy)
                  ("YAML" prettier)))
  (setq format-all-show-errors 'errors))

(my-use-package! pdf-tools
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :config
  (pdf-tools-install))

(my-use-package! projectile
  :init
  (projectile-mode 1)
  :bind-keymap
  ("C-c p" . projectile-command-map))

(provide 'plugins)
;;; plugins.el ends here
