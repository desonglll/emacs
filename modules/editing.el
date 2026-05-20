;; -*- lexical-binding: t; -*-
(global-set-key (kbd "C-c r") 'consult-recent-file)
;; (global-set-key (kbd "C-c r") 'recentf-open-files)
(global-set-key (kbd "C-<tab>") 'switch-to-next-buffer)
(global-set-key (kbd "C-S-<tab>") 'switch-to-prev-buffer)
(global-set-key (kbd "C-,") 'duplicate-line)
(global-set-key (kbd "C-c c") 'compile)
(global-set-key (kbd "<f9>") 'compile)

;; Structured pair insertion & navigation — https://github.com/Fuco1/smartparens
(use-package smartparens
  :straight t
  :hook (prog-mode . smartparens-mode)
  :config
  (sp-local-pair 'emacs-lisp-mode "'" nil :actions nil))

(use-package yasnippet
  :straight t
  :defer t
  :hook (prog-mode . yas-minor-mode)
  :config
  (setq yas-alias-to-yas/prefix-p nil)
  (yas-reload-all))

(setq yas-snippet-dirs
      (list (expand-file-name "snippets" user-emacs-directory)))

(use-package yasnippet-snippets
  :straight t
  :after yasnippet)

;; Selection expansion — https://github.com/magnars/expand-region.el
(use-package expand-region
  :straight t
  :defer t
  :bind
  ("C-=" . er/expand-region)
  ("C-+" . er/contract-region))

(use-package vimish-fold
  :straight t
  :defer t
  :hook (prog-mode . vimish-fold-mode)
  :bind (:map vimish-fold-folded-keymap
              ("<tab>" . vimish-fold-unfold)
              :map vimish-fold-unfolded-keymap
              ("<tab>" . vimish-fold-refold)))

;; Visual undo tree — https://github.com/casouri/vundo
(use-package vundo
  :straight t
  :defer t
  :bind ("C-x u" . vundo))

;; Trim whitespace only on edited lines — https://github.com/lewang/ws-butler
(use-package ws-butler
  :straight t
  :hook (prog-mode . ws-butler-mode))

;; Jump to visible characters — https://github.com/abo-abo/avy
(use-package avy
  :straight t
  :defer t
  :bind ("C-:" . avy-goto-char-2)
  ("M-g w" . avy-goto-word-1)
  ("C-M-:" . avy-goto-word-0))

(use-package link-hint
  :straight t
  :defer t
  :bind (("C-c o" . link-hint-open-link)
         ("C-c O" . link-hint-copy-link)))

;; Multiple cursors — https://github.com/magnars/multiple-cursors.el
(use-package multiple-cursors
  :straight t
  :defer t
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-<" . mc/mark-all-like-this)))

(provide 'editing)
