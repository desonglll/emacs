;;; ui.el --- User interface package configuration -*- lexical-binding: t; -*-

(defvar treemacs-width)
(defvar imenu-list-size)
(defvar imenu-list-position)

(defun my-sidebar-highlight ()
  "Use the shared selection color in directory and outline buffers."
  (setq-local hl-line-face 'my-sidebar-selection))

(add-hook 'dired-mode-hook #'my-sidebar-highlight)

(defun my-sidebar-width (&optional frame)
  "Reserve about 18 percent of FRAME for a sidebar, up to 32 columns."
  (max window-min-width (min 32 (floor (* 0.18 (frame-width frame))))))

(defun my-sidebar-display-with-width (display &rest args)
  "Call DISPLAY with ARGS using sidebar widths appropriate for this frame."
  (let ((treemacs-width (my-sidebar-width))
        (imenu-list-size (my-sidebar-width)))
    (apply display args)))

(defun my-sidebar-resize-with-frame (frame)
  "Resize visible sidebars when FRAME width changes, preserving editor focus.
Manual window resizing is left alone until the frame itself changes size."
  (unless (eq (frame-width frame) (frame-parameter frame 'my-sidebar-frame-width))
    (set-frame-parameter frame 'my-sidebar-frame-width (frame-width frame))
    (dolist (window (window-list frame 'no-minibuffer))
      (with-current-buffer (window-buffer window)
        (when (or (derived-mode-p 'treemacs-mode)
                  (and (derived-mode-p 'imenu-list-major-mode)
                       (memq imenu-list-position '(left right))))
          (let ((window-size-fixed nil))
            ;; A very narrow editor may prevent enlargement; keep its space.
            (ignore-errors
              (window-resize window (- (my-sidebar-width frame)
                                       (window-total-width window)) t))))))))

(add-hook 'window-size-change-functions #'my-sidebar-resize-with-frame)

(my-use-package! imenu-list
  :commands imenu-list
  :hook (imenu-list-major-mode . my-sidebar-highlight)
  :custom
  (imenu-list-size 32)
  (imenu-list-auto-resize nil)
  :config
  (advice-add 'imenu-list-display-buffer :around #'my-sidebar-display-with-width))

(my-use-package! treemacs
  :commands treemacs
  :custom
  (treemacs-width 32)
  (treemacs-follow-after-init t)
  (treemacs-file-follow-delay 0.3)
  :config
  (treemacs-follow-mode 1)
  (defun my-treemacs-initialize-empty-workspace (toggle &optional arg)
    "Open the current project when TOGGLE would show an empty workspace.
Keep prefix ARG's workspace selection and the usual toggle for populated trees."
    (if (or arg
            (treemacs-workspace->projects (treemacs-current-workspace)))
        (funcall toggle arg)
      (treemacs-add-and-display-current-project)))
  (advice-add 'treemacs :around #'my-treemacs-initialize-empty-workspace)
  (advice-add 'treemacs :around #'my-sidebar-display-with-width))

(my-use-package! helpful
  :bind
  (("C-h f" . helpful-callable)
   ("C-h v" . helpful-variable)
   ("C-h k" . helpful-key)
   ("C-h x" . helpful-command)))

(my-use-package! pdf-tools
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :config
  (pdf-tools-install))

(provide 'my-plugins-ui)
;;; ui.el ends here
