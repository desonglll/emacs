;;; config.el --- Native Emacs configuration -*- lexical-binding: t; -*-

;;;; Defaults

(setq inhibit-startup-screen t
      inhibit-startup-message t
      initial-scratch-message nil
      ring-bell-function #'ignore
      use-short-answers t
      confirm-kill-emacs #'yes-or-no-p
      sentence-end-double-space nil
      require-final-newline t
      tab-always-indent 'complete
      read-process-output-max (* 1024 1024))

(set-language-environment "UTF-8")
(prefer-coding-system 'utf-8-unix)
(set-default-coding-systems 'utf-8-unix)

(setq-default indent-tabs-mode nil
              tab-width 4
              fill-column 80
              truncate-lines nil)

;;;; Interface

(setq frame-title-format '("%b - Emacs")
      icon-title-format frame-title-format
      visible-bell nil
      cursor-in-non-selected-windows nil)

(column-number-mode 1)
(global-display-line-numbers-mode 1)
(global-hl-line-mode 1)
(show-paren-mode 1)

(defun my-disable-line-numbers ()
  "Disable line numbers in the current non-source buffer."
  (display-line-numbers-mode -1))

(dolist (hook '(eshell-mode-hook
                shell-mode-hook
                term-mode-hook
                vterm-mode-hook
                help-mode-hook
                special-mode-hook))
  (add-hook hook #'my-disable-line-numbers))

;;;; Editing

(delete-selection-mode 1)
(electric-pair-mode 1)
(global-auto-revert-mode 1)
(global-so-long-mode 1)

(setq auto-revert-verbose nil
      global-auto-revert-non-file-buffers t
      kill-do-not-save-duplicates t
      save-interprogram-paste-before-kill t
      scroll-conservatively 101
      mouse-wheel-progressive-speed nil)

(defun my-delete-trailing-whitespace ()
  "Delete trailing whitespace in programming and text buffers."
  (when (derived-mode-p 'prog-mode 'text-mode)
    (delete-trailing-whitespace)))

(add-hook 'before-save-hook #'my-delete-trailing-whitespace)
(keymap-global-set "C-c w" #'whitespace-mode)

;;;; Persistent state

(defconst my-backup-directory
  (expand-file-name "backups/" my-state-directory))
(defconst my-auto-save-directory
  (expand-file-name "auto-save/" my-state-directory))

(make-directory my-backup-directory t)
(make-directory my-auto-save-directory t)

(setq backup-directory-alist `(("." . ,my-backup-directory))
      auto-save-file-name-transforms `((".*" ,my-auto-save-directory t))
      auto-save-list-file-prefix
      (expand-file-name "sessions/" my-auto-save-directory)
      backup-by-copying t
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t
      savehist-file (expand-file-name "history" my-state-directory)
      save-place-file (expand-file-name "places" my-state-directory)
      recentf-save-file (expand-file-name "recentf" my-state-directory)
      recentf-max-saved-items 200
      history-length 500)

(savehist-mode 1)
(save-place-mode 1)
(recentf-mode 1)

;;;; macOS

(when (eq system-type 'darwin)
  (setq mac-command-modifier 'super
        mac-option-modifier 'meta
        ns-command-modifier 'super
        ns-alternate-modifier 'meta
        ns-option-modifier 'meta))

(my-use-package! exec-path-from-shell
  :demand t
  :custom
  (exec-path-from-shell-arguments '("-l"))
  :config
  (when (and (eq system-type 'darwin)
             (or (daemonp) (display-graphic-p)))
    (exec-path-from-shell-initialize)))

(defun my-focus-initial-frame ()
  "Give the initial graphical frame keyboard focus."
  (when (display-graphic-p)
    (select-frame-set-input-focus (selected-frame))))

(add-hook 'emacs-startup-hook #'my-focus-initial-frame)

;;;; Appearance

(defconst my-latin-font
  (font-spec :family "Iosevka Term SS15" :size 16 :weight 'regular))
(defconst my-cjk-font
  (font-spec :family "Sarasa Term SC"))

(add-to-list 'default-frame-alist '(font . "Iosevka Term SS15-16"))

(defun my-set-cjk-font (&optional frame)
  "Use Sarasa Term SC for CJK characters in FRAME."
  (let ((frame (or frame (selected-frame))))
    (when (and (display-graphic-p frame)
               (find-font my-cjk-font frame))
      (dolist (charset '(han kana cjk-misc bopomofo))
        (set-fontset-font nil charset my-cjk-font frame 'prepend)))))

(defun my-apply-fonts (&optional frame)
  "Apply the configured Latin and CJK fonts to FRAME."
  (let ((frame (or frame (selected-frame))))
    (when (and (display-graphic-p frame)
               (find-font my-latin-font frame))
      (dolist (face '(default fixed-pitch variable-pitch))
        (set-face-attribute face frame
                            :family "Iosevka Term SS15"
                            :height 160
                            :weight 'regular))
      (my-set-cjk-font frame))))

(add-hook 'after-setting-font-hook #'my-set-cjk-font)
(add-hook 'after-make-frame-functions #'my-apply-fonts)
(add-hook 'emacs-startup-hook #'my-apply-fonts)

(my-use-package! gruber-darker-theme
  :demand t
  :config
  (mapc #'disable-theme custom-enabled-themes)
  (load-theme 'gruber-darker t))

;;;; Tree-sitter

(require 'treesit)

(defconst my-treesit-language-sources
  '((c "https://github.com/tree-sitter/tree-sitter-c" "v0.23.6")
    (cpp "https://github.com/tree-sitter/tree-sitter-cpp" "v0.22.0")
    (go "https://github.com/tree-sitter/tree-sitter-go" "v0.23.4")
    (java "https://github.com/tree-sitter/tree-sitter-java" "v0.23.5")
    (python "https://github.com/tree-sitter/tree-sitter-python" "v0.23.6")
    (rust "https://github.com/tree-sitter/tree-sitter-rust" "v0.23.3"))
  "Tree-sitter grammars used by the configured language modes.")

(defconst my-treesit-mode-remaps
  '(((c cpp) c-or-c++-mode c-or-c++-ts-mode)
    (c c-mode c-ts-mode)
    (cpp c++-mode c++-ts-mode)
    (go go-mode go-ts-mode)
    (java java-mode java-ts-mode)
    (python python-mode python-ts-mode)
    (rust rust-mode rust-ts-mode))
  "Mappings from traditional modes to Tree-sitter modes.")

(dolist (source my-treesit-language-sources)
  (setf (alist-get (car source) treesit-language-source-alist)
        (cdr source)))

(defun my-refresh-treesit-mode-remaps ()
  "Prefer Tree-sitter modes for grammars that are installed."
  (dolist (mapping my-treesit-mode-remaps)
    (pcase-let ((`(,language ,base-mode ,treesit-mode) mapping))
      (when (and (fboundp treesit-mode)
                 (treesit-ready-p language t))
        (setf (alist-get base-mode major-mode-remap-alist)
              treesit-mode)))))

(defun my-install-language-grammars ()
  "Install missing Tree-sitter grammars used by this configuration."
  (interactive)
  (unless (treesit-available-p)
    (user-error "This Emacs build has no Tree-sitter support"))
  (let (failed-languages)
    (dolist (source my-treesit-language-sources)
      (let ((language (car source)))
        (unless (treesit-language-available-p language)
          (message "Installing the %s Tree-sitter grammar..." language)
          (treesit-install-language-grammar language))
        (unless (treesit-language-available-p language)
          (push language failed-languages))))
    (my-refresh-treesit-mode-remaps)
    (if failed-languages
        (user-error "Tree-sitter grammars failed: %s"
                    (mapconcat #'symbol-name
                               (nreverse failed-languages) ", "))
      (message "Configured Tree-sitter grammars are installed"))))

(my-refresh-treesit-mode-remaps)

;;;; Global key bindings

(dolist (binding
         '(("M-<f1>" . magit-status)
           ("M-<f2>" . dirvish)
           ("C-," . duplicate-line)
           ("C-:" . avy-goto-char-2)
           ("s-\\" . avy-goto-char-2)
           ("M-#" . consult-fd)
           ("C-c r" . consult-ripgrep)
           ("s-u" . revert-buffer)
           ("s-i" . imenu-list)
           ("s-e" . treemacs)
           ("M-o" . ace-window)
           ("C-c RET" . ffap)
           ("C-c f r" . recentf)))
  (keymap-global-set (car binding) (cdr binding)))

(provide 'config)
;;; config.el ends here
