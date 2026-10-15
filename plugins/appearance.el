;;; appearance.el --- Shared interface styling -*- lexical-binding: t; -*-

(my-use-package! gruber-darker-theme
  :demand t
  :config
  (mapc #'disable-theme custom-enabled-themes)
  (load-theme 'gruber-darker t))

(defconst my-ui-palette
  '((background . "#181818")
    (surface . "#222222")
    (modeline . "#2b2b2b")
    (selection . "#343230")
    (foreground . "#e4e4ef")
    (muted . "#969390")
    (subtle . "#666462")
    (border . "#303030")
    (cool . "#9ca9b6")
    (accent . "#c4b68d")
    (danger . "#d28b82")
    (success . "#95a99f")
    (magenta . "#b19aac")
    (cyan . "#94b4b0"))
  "Shared interface colors complementing Gruber Darker.")

(defface my-sidebar-selection '((t (:inherit hl-line)))
  "Shared selection face for directory and outline sidebars."
  :group 'faces)

;; User theme specs also apply to faces defined by deferred packages.
(let-alist my-ui-palette
  (custom-theme-set-faces
   'user
   `(fringe ((t (:background ,.background :foreground ,.subtle))))
   `(line-number ((t (:background ,.background :foreground ,.subtle))))
   `(line-number-current-line
     ((t (:background ,.background :foreground ,.muted :weight normal))))
   `(hl-line ((t (:background ,.surface))))
   `(region ((t (:background ,.selection :foreground unspecified :extend t))))
   `(match ((t (:background ,.selection :foreground ,.accent :weight bold))))
   `(isearch ((t (:background ,.accent :foreground ,.background :weight bold))))
   `(lazy-highlight ((t (:background ,.selection :foreground ,.foreground))))
   `(isearch-fail ((t (:background ,.danger :foreground ,.background))))
   `(show-paren-match
     ((t (:background ,.selection :foreground ,.accent :weight bold))))
   `(show-paren-mismatch
     ((t (:background ,.selection :foreground ,.danger :weight bold))))
   `(flymake-error ((t (:underline (:style wave :color ,.danger)))))
   `(flymake-warning ((t (:underline (:style wave :color ,.accent)))))
   `(flymake-note ((t (:underline (:style wave :color ,.cool)))))
   `(flymake-error-echo ((t (:foreground ,.danger))))
   `(flymake-warning-echo ((t (:foreground ,.accent))))
   `(flymake-note-echo ((t (:foreground ,.cool))))
   `(vertical-border ((t (:foreground ,.border))))
   `(window-divider ((t (:foreground ,.border))))
   `(window-divider-first-pixel ((t (:foreground ,.border))))
   `(window-divider-last-pixel ((t (:foreground ,.border))))
   `(mode-line
     ((t (:background ,.modeline :foreground ,.foreground :box nil :weight normal))))
   `(mode-line-active ((t (:inherit mode-line))))
   `(mode-line-inactive
     ((t (:background ,.background :foreground ,.muted :box nil :weight normal))))
   ;; Do not inherit the theme's separate background behind the filename.
   `(mode-line-buffer-id ((t (:background unspecified :weight bold))))
   `(doom-modeline-buffer-file ((t (:foreground ,.foreground :weight bold))))
   `(doom-modeline-buffer-path ((t (:foreground ,.muted))))
   `(doom-modeline-buffer-modified ((t (:foreground ,.accent :weight bold))))
   `(doom-modeline-buffer-major-mode ((t (:foreground ,.muted :weight normal))))
   `(doom-modeline-project-parent-dir ((t (:foreground ,.muted :weight normal))))
   `(doom-modeline-project-dir ((t (:foreground ,.cool :weight normal))))
   `(doom-modeline-project-root-dir ((t (:foreground ,.cool :weight normal))))
   `(doom-modeline-project-name ((t (:foreground ,.cool :weight normal :slant normal))))
   `(doom-modeline-vcs-default ((t (:foreground ,.cool :weight normal))))
   `(doom-modeline-info ((t (:foreground ,.cool :weight normal))))
   `(doom-modeline-warning ((t (:foreground ,.accent :weight normal))))
   `(doom-modeline-urgent ((t (:foreground ,.danger :weight bold))))
   `(doom-modeline-bar ((t (:background ,.accent))))
   `(doom-modeline-bar-inactive ((t (:background ,.border))))
   `(vertico-current
     ((t (:background ,.selection :foreground ,.foreground :weight normal))))
   `(company-tooltip ((t (:background ,.surface :foreground ,.foreground))))
   `(company-tooltip-selection
     ((t (:background ,.selection :foreground ,.foreground :weight normal))))
   `(company-tooltip-common ((t (:foreground ,.accent :weight bold))))
   `(company-tooltip-common-selection ((t (:inherit company-tooltip-common))))
   `(company-tooltip-annotation ((t (:foreground ,.muted))))
   `(company-tooltip-annotation-selection
     ((t (:inherit company-tooltip-annotation))))
   `(company-tooltip-scrollbar-track ((t (:background ,.surface))))
   `(company-tooltip-scrollbar-thumb ((t (:background ,.subtle))))
   `(company-preview-common ((t (:foreground ,.muted))))
   `(treemacs-window-background-face ((t (:background ,.background))))
   `(treemacs-hl-line-face ((t (:background ,.selection :extend t))))
   `(treemacs-root-face
     ((t (:foreground ,.cool :weight bold :height 1.0 :underline nil))))
   `(treemacs-directory-face ((t (:foreground ,.cool :weight normal))))
   `(treemacs-directory-collapsed-face ((t (:foreground ,.muted))))
   `(treemacs-file-face ((t (:foreground ,.foreground))))
   `(treemacs-git-unmodified-face ((t (:foreground ,.foreground))))
   `(treemacs-git-modified-face ((t (:foreground ,.accent))))
   `(treemacs-git-renamed-face ((t (:foreground ,.cool))))
   `(treemacs-git-ignored-face ((t (:foreground ,.subtle))))
   `(treemacs-git-untracked-face ((t (:foreground ,.success))))
   `(treemacs-git-added-face ((t (:foreground ,.success))))
   `(treemacs-git-conflict-face ((t (:foreground ,.danger :weight bold))))
   `(treemacs-fringe-indicator-face ((t (:foreground ,.accent))))
   `(treemacs-header-button-face ((t (:foreground ,.muted))))
   `(treemacs-on-success-pulse-face ((t (:background ,.selection :extend t))))
   `(treemacs-on-failure-pulse-face
     ((t (:background ,.selection :foreground ,.danger :extend t))))
   `(dired-directory ((t (:foreground ,.cool :weight normal))))
   `(dired-symlink ((t (:foreground ,.cyan))))
   `(dired-marked ((t (:foreground ,.accent :weight bold))))
   `(dired-flagged ((t (:foreground ,.danger :weight bold))))
   `(diff-hl-insert ((t (:foreground ,.success :background ,.success))))
   `(diff-hl-change ((t (:foreground ,.cool :background ,.cool))))
   `(diff-hl-delete ((t (:foreground ,.danger :background ,.danger))))
   `(diff-hl-dired-unknown ((t (:inherit diff-hl-dired-insert))))
   `(dirvish-hl-line ((t (:background ,.selection :extend t))))
   `(dirvish-hl-line-inactive ((t (:background ,.surface :extend t))))
   `(dirvish-proc-running ((t (:foreground ,.accent))))
   `(dirvish-proc-finished ((t (:foreground ,.success))))
   `(dirvish-proc-failed ((t (:foreground ,.danger))))
   `(my-sidebar-selection ((t (:background ,.selection :extend t))))
   `(imenu-list-entry-face ((t (:foreground ,.foreground))))
   `(eat-shell-prompt-annotation-running ((t (:foreground ,.muted))))
   `(eat-shell-prompt-annotation-success ((t (:foreground ,.success))))
   `(eat-shell-prompt-annotation-failure ((t (:foreground ,.danger))))
   `(pulsar-generic ((t (:background ,.selection :extend t))))
   `(org-modern-label ((t (:inherit fixed-pitch :height 0.9 :weight normal))))
   `(org-modern-todo
     ((t (:background ,.selection :foreground ,.accent :inherit org-modern-label))))
   `(org-modern-done
     ((t (:background ,.surface :foreground ,.success :inherit org-modern-label))))
   `(org-modern-tag
     ((t (:background ,.surface :foreground ,.muted :inherit org-modern-label))))))

;; Keep the outline hierarchy readable without a different bright color per level.
(dotimes (depth 4)
  (custom-theme-set-faces
   'user
   `(,(intern (format "imenu-list-entry-face-%d" depth))
     ((t (:foreground ,(alist-get (if (zerop depth) 'cool 'foreground)
                                  my-ui-palette)))))
   `(,(intern (format "imenu-list-entry-subalist-face-%d" depth))
     ((t (:foreground ,(alist-get 'cool my-ui-palette)
          :weight bold :underline nil))))))

;; Emacs 28+ Eat inherits ANSI faces; term.el uses the older term-color faces.
(require 'color)
(dolist (entry '((black . background) (red . danger) (green . success)
                 (yellow . accent) (blue . cool) (magenta . magenta)
                 (cyan . cyan) (white . foreground)))
  (let* ((name (symbol-name (car entry)))
         (normal (alist-get (cdr entry) my-ui-palette))
         (bright (if (eq (car entry) 'black)
                     (alist-get 'subtle my-ui-palette)
                   (color-lighten-name normal 12))))
    (dolist (prefix '("ansi-color-" "term-color-"))
      (custom-theme-set-faces
       'user `(,(intern (concat prefix name))
               ((t (:foreground ,normal :background ,normal))))))
    (custom-theme-set-faces
     'user `(,(intern (concat "ansi-color-bright-" name))
             ((t (:foreground ,bright :background ,bright)))))))

(defconst my-ui-frame-spacing
  '((internal-border-width . 10)
    (left-fringe . 8)
    (right-fringe . 8))
  "Modest padding shared by existing and newly created frames.")

(dolist (parameter my-ui-frame-spacing)
  (setf (alist-get (car parameter) default-frame-alist) (cdr parameter)))
(modify-all-frames-parameters my-ui-frame-spacing)
(setq window-divider-default-right-width 1
      window-divider-default-bottom-width 1
      window-divider-default-places t)
(window-divider-mode 1)

(defun my-ui-buffer-spacing ()
  "Give source and prose a little breathing room without altering terminal grids."
  (setq-local line-spacing 0.1))

(add-hook 'prog-mode-hook #'my-ui-buffer-spacing)
(add-hook 'text-mode-hook #'my-ui-buffer-spacing)

(my-use-package! doom-modeline
  :hook (after-init . doom-modeline-mode)
  :custom
  (doom-modeline-height 28)
  (doom-modeline-bar-width 2)
  (doom-modeline-buffer-file-name-style 'relative-from-project)
  (doom-modeline-vcs-max-length most-positive-fixnum)
  (doom-modeline-major-mode-color-icon nil)
  (doom-modeline-buffer-encoding nil)
  (doom-modeline-env-version nil)
  (doom-modeline-minor-modes nil)
  (doom-modeline-check 'simple)
  :config
  (doom-modeline-def-modeline 'main
    '(bar matches buffer-info remote-host buffer-position selection-info)
    '(input-method major-mode process vcs check)))

(my-use-package! nerd-icons
  :custom
  (nerd-icons-color-icons nil))

(my-use-package! nerd-icons-completion
  :after marginalia
  :demand t
  :config
  (nerd-icons-completion-mode 1)
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

(defun my-enable-indent-bars ()
  "Show indentation guides in ordinary-sized source buffers."
  (unless (my-large-buffer-p)
    (indent-bars-mode 1)))

(my-use-package! indent-bars
  :commands indent-bars-mode
  :hook (prog-mode . my-enable-indent-bars)
  :custom
  ;; The standard macOS NS build does not render stipple bars reliably.
  (indent-bars-prefer-character (eq system-type 'darwin))
  (indent-bars-color '(line-number :blend 0.5))
  (indent-bars-color-by-depth nil)
  (indent-bars-highlight-current-depth '(:face line-number :blend 1))
  (indent-bars-pattern ".")
  (indent-bars-width-frac 0.1)
  (indent-bars-pad-frac 0.1))

(my-use-package! pulsar
  :hook (after-init . pulsar-global-mode)
  :custom
  (pulsar-delay 0.04)
  (pulsar-iterations 6)
  (pulsar-face 'pulsar-generic)
  :config
  (dolist (hook '(consult-after-jump-hook imenu-after-jump-hook xref-after-jump-hook))
    (add-hook hook #'pulsar-pulse-line)))

(defun my-enable-org-modern ()
  "Decorate ordinary-sized Org buffers."
  (unless (my-large-buffer-p)
    (org-modern-mode 1)))

(my-use-package! org-modern
  :commands org-modern-mode
  :hook
  ((org-mode . my-enable-org-modern)
   (org-agenda-finalize . org-modern-agenda))
  :custom
  (org-modern-star 'replace)
  (org-modern-replace-stars "◉○•")
  (org-modern-table-vertical 1)
  (org-modern-table-horizontal 0.1))

(provide 'my-plugins-appearance)
;;; appearance.el ends here
