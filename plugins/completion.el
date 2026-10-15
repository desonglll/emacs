;;; completion.el --- Completion package configuration -*- lexical-binding: t; -*-

;;;; Completion history

(my-use-package! prescient
  :demand t
  :custom
  (prescient-save-file
   (expand-file-name "prescient-save.el" my-state-directory))
  :config
  (prescient-persist-mode 1))

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

(my-use-package! vertico-prescient
  :after vertico
  :demand t
  :custom
  ;; Keep Orderless matching; learn only the candidate order.
  (vertico-prescient-enable-filtering nil)
  (vertico-prescient-enable-sorting t)
  :config
  (vertico-prescient-mode 1))

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

(my-use-package! wgrep
  :after grep
  :demand t
  :custom
  ;; Review the edited file buffers before saving them.
  (wgrep-auto-save-buffer nil))

;;;; In-buffer

(defvar my-company-idle-delay 0.15
  "Idle delay used when automatic Company completion is enabled.")

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
  (setq company-idle-delay my-company-idle-delay
        company-minimum-prefix-length 2
        company-selection-wrap-around t
        company-tooltip-limit 12))

(my-use-package! company-prescient
  :after company
  :demand t
  :custom
  ;; Keep the backend's order for candidates without usage history.
  (company-prescient-sort-length-enable nil)
  :config
  (company-prescient-mode 1))

(my-use-package! cape
  :bind
  (("M-/" . cape-dabbrev)
   ("C-c c f" . cape-file)
   ("C-c c k" . cape-keyword))
  :init
  (add-hook 'completion-at-point-functions #'cape-dabbrev 90)
  (add-hook 'completion-at-point-functions #'cape-file 100))

(provide 'my-plugins-completion)
;;; completion.el ends here
