;;; ui-appearance.el --- Fonts, frames, and theme -*- lexical-binding: t; -*-

(defconst my-latin-font
  (font-spec :family "Iosevka Term SS15" :size 16 :weight 'regular))
(defconst my-cjk-font
  (font-spec :family "Sarasa Term SC"))

(add-to-list 'default-frame-alist '(font . "Iosevka Term SS15-16"))

(defun my-set-cjk-font (&optional frame)
  "Use Sarasa Term SC for CJK characters in FRAME."
  (let ((frame (or frame (selected-frame))))
    (when (and (display-graphic-p frame)
               (find-font my-cjk-font frame))
      (dolist (charset '(han kana cjk-misc bopomofo))
        (set-fontset-font nil charset my-cjk-font frame 'prepend)))))

(defun my-apply-fonts (&optional frame)
  "Apply the configured Latin and CJK fonts to FRAME."
  (let ((frame (or frame (selected-frame))))
    (when (and (display-graphic-p frame)
               (find-font my-latin-font frame))
      (dolist (face '(default fixed-pitch variable-pitch))
        (set-face-attribute face frame
                            :family "Iosevka Term SS15"
                            :height 160
                            :weight 'regular))
      (my-set-cjk-font frame))))

(add-hook 'after-setting-font-hook #'my-set-cjk-font)
(add-hook 'after-make-frame-functions #'my-apply-fonts)
(add-hook 'emacs-startup-hook #'my-apply-fonts)

(straight-use-package 'gruber-darker-theme)
(mapc #'disable-theme custom-enabled-themes)
(load-theme 'gruber-darker t)

(provide 'ui-appearance)
;;; ui-appearance.el ends here
