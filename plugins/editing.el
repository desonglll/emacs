;;; editing.el --- Editing package configuration -*- lexical-binding: t; -*-

;;;; Snippets

(my-use-package! yasnippet
  :demand t
  :init
  ;; Register the collection before its autoload runs, so `yas-global-mode'
  ;; indexes all directories once instead of scanning the collection twice.
  (defvar yas-snippet-dirs
    (list (expand-file-name "snippets" user-emacs-directory)))
  (setq yas-snippet-dirs (ensure-list yas-snippet-dirs))
  (add-to-list 'yas-snippet-dirs 'yasnippet-snippets-dir t)
  :config
  (yas-global-mode 1))

(my-use-package! yasnippet-snippets
  :after yasnippet
  :demand t)

;;;; Selection and undo

(my-use-package! expreg
  :bind
  (("C-=" . expreg-expand)
   ("C-M-=" . expreg-contract)))

(my-use-package! vundo
  :bind
  ("C-x u" . vundo))

(my-use-package! iedit
  :init
  (setq iedit-toggle-key-default nil)
  :bind
  ("C-c e" . iedit-mode))

(my-use-package! hl-todo
  :hook (after-init . global-hl-todo-mode)
  :bind
  (:map hl-todo-mode-map
        ("C-c t n" . hl-todo-next)
        ("C-c t p" . hl-todo-previous)
        ("C-c t o" . hl-todo-occur)))

;;;; Navigation and buffers

(my-use-package! ace-window
  :commands ace-window)

(my-use-package! avy
  :commands avy-goto-char-2)

;;;; Input and text

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

(my-use-package! pyim-tsinghua-dict
  :after pyim
  :config
  (pyim-tsinghua-dict-enable))

(my-use-package! translate
  :commands (translate-trans translate-argo translate-volcengine translate-volcengine-ark)
  :init
  (setq translate-volcengine-api-key
        (or (getenv "VOLCENGINE_TRANSLATE_API_KEY")
            (getenv "VOLCENGINE_API_KEY")))
  (setq translate-volcengine-ark-api-key
        (or (getenv "ARK_API_KEY")
            (getenv "VOLCENGINE_ARK_API_KEY"))))

(defun my-enable-diff-hl ()
  "Enable Git gutter updates for ordinary-sized buffers."
  (unless (my-large-buffer-p)
    (diff-hl-mode 1)))

(my-use-package! diff-hl
  :commands diff-hl-mode
  :hook ((prog-mode . my-enable-diff-hl)
         (text-mode . my-enable-diff-hl))
  :custom
  (diff-hl-flydiff-delay 0.8)
  :config
  (global-diff-hl-mode)
  (diff-hl-flydiff-mode))

(provide 'my-plugins-editing)
;;; editing.el ends here
