;;; theme-selection.el --- Select and remember color themes -*- lexical-binding: t; -*-

(defgroup my-appearance nil
  "Personal interface preferences."
  :group 'faces)

(defconst my-theme-choices
  '(gruber-darker doom-one doom-nord doom-gruvbox doom-tokyo-night
    modus-vivendi modus-operandi)
  "Themes offered by `my-select-theme'.")

(defcustom my-preferred-theme 'gruber-darker
  "Theme restored at startup and saved by `my-select-theme'."
  :type 'symbol
  :group 'my-appearance)

(defun my-sync-gruber-ui (theme)
  "Keep Gruber-specific interface colors with the active base THEME."
  (unless (eq theme 'my-gruber-ui)
    (let ((gruber-active
           (eq (car (remq 'my-gruber-ui custom-enabled-themes)) 'gruber-darker))
          (overlay-active (custom-theme-enabled-p 'my-gruber-ui)))
      (cond ((and gruber-active (not overlay-active))
             (enable-theme 'my-gruber-ui))
            ((and (not gruber-active) overlay-active)
             (disable-theme 'my-gruber-ui))))))

(add-hook 'enable-theme-functions #'my-sync-gruber-ui)
(add-hook 'disable-theme-functions #'my-sync-gruber-ui)

(defun my-load-theme (theme &optional remember)
  "Activate only THEME, saving the choice when REMEMBER is non-nil."
  ;; Load before disabling the current theme so a missing file leaves it intact.
  (load-theme theme t t)
  (let ((previous custom-enabled-themes))
    (mapc #'disable-theme custom-enabled-themes)
    (condition-case err
        (enable-theme theme)
      (error
       (mapc #'disable-theme custom-enabled-themes)
       (mapc #'enable-theme (reverse previous))
       (signal (car err) (cdr err)))))
  (setq my-preferred-theme theme)
  (when remember
    (customize-save-variable 'my-preferred-theme theme)
    (message "已切换主题：%s" theme)))

(defun my-select-theme ()
  "Choose a color theme and remember it for future Emacs sessions."
  (interactive)
  (my-load-theme
   (intern (completing-read "主题："
                            (mapcar #'symbol-name my-theme-choices)
                            nil t nil nil (symbol-name my-preferred-theme)))
   t))

(provide 'my-theme-selection)
;;; theme-selection.el ends here
