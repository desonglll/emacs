;; -*- lexical-binding: t; -*-
;; Vertical completion UI — https://github.com/minad/vertico
(use-package vertico
  :straight t
  :init (vertico-mode 1)
  :config
  (vertico-indexed-mode 1)
  (setq vertico-cycle t
        vertico-preselect-input t)
  :bind (:map vertico-map
              ("RET" . vertico-directory-enter)
              ("DEL" . vertico-directory-delete-char)
              ("C-j" . vertico-exit-input)
              ))

;; Fuzzy completion style — https://github.com/oantolin/orderless
(use-package orderless
  :straight t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

;; Minibuffer annotations — https://github.com/minad/marginalia
(use-package marginalia
  :straight t
  :init (marginalia-mode 1))

;; Search & navigation commands — https://github.com/minad/consult
(use-package consult
  :straight t
  :bind (("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ("C-c r" . consult-recent-file)
         ([remap Info-search] . consult-info)
         ("C-x M-:" . consult-complex-command)
         ("C-x b" . consult-buffer)
         ("C-x 4 b" . consult-buffer-other-window)
         ("C-x 5 b" . consult-buffer-other-frame)
         ("C-x t b" . consult-buffer-other-tab)
         ("C-x r b" . consult-bookmark)
         ("C-x p b" . consult-project-buffer)
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)
         ("C-M-#" . consult-register)
         ("M-y" . consult-yank-pop)
         ("M-g e" . consult-compile-error)
         ("M-g r" . consult-grep-match)
         ("M-g f" . consult-flycheck)
         ("M-g g" . consult-goto-line)
         ("M-g M-g" . consult-goto-line)
         ("M-g o" . consult-outline)
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ("M-s d" . consult-fd)
         ("M-s c" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)
         ("M-s e" . consult-isearch-history)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         :map minibuffer-local-map
         ("M-s" . consult-history)
         ("M-r" . consult-history))
  :config
  (setq consult-narrow-key "<"
        consult-fd-args '("fd" "--color=never" "--hidden" "--full-path"))
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep consult-man
   consult-bookmark consult-recent-file consult-xref
   consult-source-bookmark consult-source-file-register
   consult-source-recent-file consult-source-project-recent-file
   :preview-key '(:debounce 0.4 any)))

;; Directory navigation — https://github.com/karthink/consult-dir
(use-package consult-dir
  :straight t
  :defer t
  :bind (("C-x C-d" . consult-dir)
         :map vertico-map
         ("C-x C-d" . consult-dir)
         ("C-x C-j" . consult-dir-jump-file)))

;; Eglot symbol search — https://github.com/jdtsmith/consult-eglot
(use-package consult-eglot
  :straight t
  :defer t
  :bind (:map eglot-mode-map ("M-." . consult-eglot-symbols)))

;; Contextual actions — https://github.com/oantolin/embark
(use-package embark
  :straight t
  :defer t
  :bind (("C-." . embark-act)
         ("C-;" . embark-dwim)))

;; Embark + Consult integration — https://github.com/oantolin/embark
(use-package embark-consult
  :straight t
  :defer t
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))

(use-package wgrep
  :straight t
  :after consult
  :config
  (setq wgrep-auto-save-buffer t
        wgrep-change-readonly-file t))

(use-package affe
  :straight t
  :after orderless
  :config
  (setq affe-regexp-function #'orderless-pattern-compiler))

;; In-buffer completion popup — https://github.com/minad/corfu
(use-package corfu
  :straight t
  :init (global-corfu-mode)
  :custom
  (corfu-auto nil)
  (corfu-cycle t)
  :config
  (corfu-popupinfo-mode 1)
  (corfu-history-mode 1)
  (add-to-list 'savehist-additional-variables 'corfu-history)
  (require 'corfu-info)
  :bind (:map corfu-map
              ("M-TAB" . corfu-next)
              ([tab] . corfu-next)
              ("S-M-TAB" . corfu-previous)
              ([backtab] . corfu-previous)
              ("M-n" . corfu-popupinfo-scroll-up)
              ("M-p" . corfu-popupinfo-scroll-down)))

;; Completion backends — https://github.com/minad/cape
(use-package cape
  :straight t
  :defer t
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-elisp-block)
  ;; (add-to-list 'completion-at-point-functions #'cape-yasnippet)
  )

;; Icons in minibuffer completion — https://github.com/rainstormstudio/nerd-icons-completion
(use-package nerd-icons-completion
  :straight t
  :after marginalia
  :config (nerd-icons-completion-mode))

;; Icons in corfu popup — https://github.com/LuigiPiucco/nerd-icons-corfu
(use-package nerd-icons-corfu
  :straight t
  :after corfu
  :config (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

;; Better help buffers — https://github.com/Wilfred/helpful
(use-package helpful
  :straight t
  :defer t
  :bind (([remap describe-function] . helpful-callable)
         ([remap describe-variable] . helpful-variable)
         ([remap describe-key] . helpful-key)
         ([remap describe-command] . helpful-command)))

;; Keybinding hints popup — https://github.com/justbur/emacs-which-key
(use-package which-key
  :straight t
  :init (which-key-mode))

(provide 'completion)
