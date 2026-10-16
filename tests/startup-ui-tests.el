;;; startup-ui-tests.el --- Theme and annotation regressions -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)
(require 'marginalia)
(require 'vertico)
(require 'diff-mode)

(ert-deftest my-completion-annotates-commands-without-a-visible-buffer ()
  ;; Reproduce the nil window width through Vertico's real metadata pipeline,
  ;; including Marginalia and Nerd Icons advice.
  (with-temp-buffer
    (should-not (get-buffer-window-list))
    (let* ((vertico--metadata '(metadata (category . command)))
           (candidates '("cd" "fd-cd"))
           (result (vertico--affixate candidates)))
      (should (equal (mapcar #'car result) candidates))
      (dolist (entry result)
        (should (stringp (nth 1 entry)))
        (should (> (length (nth 2 entry)) 0))))))

(ert-deftest my-completion-keeps-window-width-and-original-buffer-context ()
  (let ((original (current-buffer))
        (completion (generate-new-buffer " *annotation-test*")))
    (unwind-protect
        (save-window-excursion
          (delete-other-windows)
          (switch-to-buffer completion)
          (let* ((narrow (split-window-right 30))
                 (expected-width (/ (min (window-width) (window-width narrow)) 2))
                 (marginalia-field-width 1000)
                 (minibuffer--original-buffer original)
                 (marginalia--cache nil))
            (set-window-buffer narrow completion)
            (marginalia--affixate
             '(metadata (category . command))
             (lambda (_candidate)
               (should (eq (current-buffer) original))
               (should (= marginalia-field-width expected-width))
               "annotation")
             '("cd"))))
      (kill-buffer completion))))

(ert-deftest my-completion-window-fallback-is-scoped-and-restored-on-error ()
  (let ((get-windows (symbol-function 'get-buffer-window-list)))
    (with-temp-buffer
      (let ((buffer (current-buffer))
            (minibuffer--original-buffer (current-buffer))
            (marginalia--cache nil))
        (should-error
         (marginalia--affixate
          '(metadata (category . command))
          (lambda (_candidate)
            (should (numberp marginalia-field-width))
            ;; Explicit buffer queries and unrelated buffers keep their meaning.
            (should-not (get-buffer-window-list buffer))
            (with-temp-buffer (should-not (get-buffer-window-list)))
            (signal 'user-error '("Annotation failure")))
          '("cd"))
         :type 'user-error)))
    (should (eq (symbol-function 'get-buffer-window-list) get-windows))))

(ert-deftest my-gruber-theme-reloads-with-valid-face-colors ()
  (let (invalid-colors)
    (cl-letf* ((set-face (symbol-function 'set-face-attribute))
               ((symbol-function 'set-face-attribute)
                (lambda (face frame &rest attributes)
                  (dolist (attribute '(:foreground :background))
                    (when (and (plist-member attributes attribute)
                               (null (plist-get attributes attribute)))
                      (push (list face attribute) invalid-colors)))
                  (apply set-face face frame attributes))))
      (disable-theme 'gruber-darker)
      (load-theme 'gruber-darker t)
      ;; Exercise delayed package faces as well as the startup faces.
      (dolist (face '(tab-bar-tab tab-bar-tab-inactive highlight
                     secondary-selection region fringe diff-added diff-removed))
        (face-spec-recalc face (selected-frame))))
    (should-not invalid-colors)
    (should (eq (face-attribute 'mode-line :box nil) nil))
    (should (equal (face-attribute 'region :background nil)
                   (alist-get 'selection my-ui-palette)))))

;;; startup-ui-tests.el ends here
