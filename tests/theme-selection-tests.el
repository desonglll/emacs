;;; theme-selection-tests.el --- Theme switching regressions -*- lexical-binding: t; -*-

(require 'ert)

(ert-deftest my-themes-switch-without-leaking-gruber-interface-colors ()
  (let ((original my-preferred-theme))
    (unwind-protect
        (dolist (theme my-theme-choices)
          (my-load-theme theme)
          (if (eq theme 'gruber-darker)
              (progn
                (should (equal custom-enabled-themes
                               '(my-gruber-ui gruber-darker)))
                (should (equal (face-attribute 'region :background nil)
                               (alist-get 'selection my-ui-palette))))
            (should (equal custom-enabled-themes (list theme)))
            (dolist (face '(region mode-line))
              (should-not
               (equal (face-attribute face :background nil)
                      (alist-get (if (eq face 'region) 'selection 'modeline)
                                 my-ui-palette))))))
      (my-load-theme original))))

(ert-deftest my-theme-selection-saves-a-reloadable-preference ()
  (let* ((directory (make-temp-file "emacs-theme-test-" t))
         (custom-file (expand-file-name "custom.el" directory))
         ;; Customize intentionally refuses to save when Emacs starts with -Q.
         (user-init-file (expand-file-name "init.el" my-config-directory))
         (original my-preferred-theme))
    (unwind-protect
        (progn
          (my-load-theme 'doom-nord t)
          (should (file-exists-p custom-file))
          (setq my-preferred-theme 'gruber-darker)
          (load custom-file nil 'nomessage)
          (should (eq my-preferred-theme 'doom-nord)))
      (my-load-theme original)
      (delete-directory directory t))))

(ert-deftest my-theme-binding-keeps-terminal-shortcuts ()
  (should (eq (key-binding (kbd "C-c u t")) #'my-select-theme))
  (should (eq (key-binding (kbd "C-c t t")) #'my-terminal-toggle))
  (should (eq (key-binding (kbd "C-c t s")) #'my-terminal-select))
  (should (eq (key-binding (kbd "C-c t r")) #'my-terminal-rename))
  (should-not (eq (key-binding (kbd "C-c t T")) #'my-select-theme)))

;;; theme-selection-tests.el ends here
