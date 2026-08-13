;;; completion.el --- Completion package configuration -*- lexical-binding: t; -*-

;;;; Minibuffer

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

;;;; In-buffer

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
                        :weight 'bold)
    )
  )

(my-use-package! cape
  :bind
  (("M-/" . cape-dabbrev)
   ("C-c p f" . cape-file)
   ("C-c p k" . cape-keyword))
  :init
  (add-hook 'completion-at-point-functions #'cape-dabbrev 90)
  (add-hook 'completion-at-point-functions #'cape-file 100))

(provide 'my-completion)
;;; completion.el ends here
