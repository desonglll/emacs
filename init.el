;; -*- lexical-binding: t; -*-
(setq gc-cons-threshold most-positive-fixnum)
(defvar default-file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq file-name-handler-alist default-file-name-handler-alist)))

(when (eq system-type 'darwin)
  (setenv "PATH" (concat "/opt/homebrew/bin:/opt/homebrew/sbin:" (getenv "PATH")))
  (add-to-list 'exec-path "/opt/homebrew/bin")
  (setenv "LIBRARY_PATH"
          (concat (string-trim (shell-command-to-string "brew --prefix libgccjit"))
                  "/lib/gcc/13")))

(setq read-process-output-max (* 1024 1024))
(setq-default bidi-paragraph-direction 'left-to-right
              bidi-inhibit-bpa t)

(setq straight-check-for-modifications '(check-on-save find-when-checking))
(setq save-interprogram-paste-before-kill t)

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el"
                         (or (bound-and-true-p straight-base-dir) user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Keep config directory tidy — https://github.com/emacscollective/no-littering
(use-package no-littering
  :straight t)

;; Auto-compile elisp on load/save — https://github.com/emacscollective/auto-compile
(use-package auto-compile
  :straight t
  :demand t
  :config
  (auto-compile-on-load-mode)
  (auto-compile-on-save-mode))

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(setq backup-directory-alist `(("" . ,(expand-file-name "backups" user-emacs-directory))))

;; Garbage collection tuner — https://github.com/emacsmirror/gcmh
(use-package gcmh
  :straight t
  :init (gcmh-mode 1))

;; Startup profiler — https://github.com/dholm/benchmark-init-el
(use-package benchmark-init
  :straight t
  :demand t
  :config
  (add-hook 'after-init-hook 'benchmark-init/deactivate))

(setq uniquify-buffer-name-style 'forward
      uniquify-separator "/"
      uniquify-after-kill-buffer-p t)

(savehist-mode 1)

(add-to-list 'load-path (expand-file-name "modules" user-emacs-directory))
(require 'rc)
(require 'ui)
(require 'completion)
(require 'editing)
(require 'dev)
(require 'ai)

(when (file-exists-p custom-file)
  (load custom-file))

(set-face-attribute 'default nil
                    :family "Iosevka Term SS15"
                    :height 180)

(set-fontset-font t 'symbol
                  (font-spec :family "Symbols Nerd Font Mono") nil 'prepend)

(set-fontset-font t 'symbol
                  (font-spec :family "Apple Color Emoji") nil 'prepend)

(provide 'init)
;;; init.el ends here
