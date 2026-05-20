;;; package --- Summary ;;; -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(auto-revert-avoid-polling t)
 '(backup-directory-alist '(("" . "~/.config/emacs/backups")))
 '(change-major-mode-with-file-name t)
 '(default-frame-alist '((fullscreen . maximized)))
 '(delete-selection-mode t)
 '(delete-trailing-lines t)
 '(dired-auto-revert-buffer t)
 '(dired-dwim-target t)
 '(dired-recursive-copies 'always)
 '(dired-recursive-deletes 'always)
 '(dired-use-ls-dired nil)
 '(display-line-numbers t)
 '(display-time-day-and-date t)
 '(duplicate-line-final-position 1)
 '(duplicate-region-final-position -1)
 '(electric-indent-mode t)
 '(electric-pair-mode t)
 '(electric-pair-skip-whitespace t)
 '(electric-quote-mode nil)
 '(global-auto-revert-mode t)
 '(indent-tabs-mode nil)
 '(inhibit-startup-screen t)
 '(menu-bar-mode nil)
 '(ns-pop-up-frames nil)
 '(ns-right-alternate-modifier nil)
 '(package-selected-packages '(company smex))
 '(ps-font-family 'Iosevka)
 '(recentf-max-menu-items 25)
 '(recentf-mode t)
 '(scroll-bar-mode nil)
 '(scroll-consistently t)
 '(scroll-margin 0)
 '(scroll-step 1)
 '(tab-always-indent 'complete)
 '(tab-width 4)
 '(tool-bar-mode nil)
 '(tooltip-frame-parameters
   '((name . "tooltip") (internal-border-width . 2) (border-width . 1)
     (no-special-glyphs . t)))
 '(use-short-answers t)
 '(visible-bell t)
 '(what-cursor-show-names t)
 '(winner-mode t))

(provide 'custom)
