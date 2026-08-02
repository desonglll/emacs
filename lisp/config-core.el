;;; config-core.el --- Core editor behavior and appearance -*- lexical-binding: t; -*-

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

(use-package exec-path-from-shell
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

(straight-use-package 'gruber-darker-theme)
(mapc #'disable-theme custom-enabled-themes)
(load-theme 'gruber-darker t)

(provide 'config-core)
;;; config-core.el ends here
