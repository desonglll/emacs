;;; buffer-performance-tests.el --- Editing regression checks -*- lexical-binding: t; -*-

;; Run after early-init.el, init.el, after-init-hook and emacs-startup-hook
;; in an isolated `emacs -Q --batch' process.
(require 'ert)
(require 'cl-lib)

(ert-deftest my-large-buffer-counts-bytes-even-when-narrowed ()
  (with-temp-buffer
    (let ((my-large-buffer-threshold 8))
      (insert "中文测试")
      (narrow-to-region 1 2)
      (should (my-large-buffer-p))
      (should (= (- (point-max) (point-min)) 1)))))

(ert-deftest my-large-buffer-skips-automatic-extras ()
  (with-temp-buffer
    (let ((my-large-buffer-threshold 32))
      (insert (make-string 64 ?x))
      (emacs-lisp-mode)
      ;; Simulate the global modes revisiting buffers after initialization.
      (diff-hl--global-turn-on)
      (hl-todo--turn-on-mode-if-desired)
      (should-not display-line-numbers)
      (should-not company-idle-delay)
      (should-not (bound-and-true-p indent-bars-mode))
      (should-not (bound-and-true-p diff-hl-mode))
      (should-not (bound-and-true-p hl-todo-mode))
      (should-not (memq #'format/initialize-on-first-save before-save-hook)))))

(ert-deftest my-small-buffer-keeps-editing-extras ()
  (with-temp-buffer
    (insert "(message \"small\")\n")
    (emacs-lisp-mode)
    (should indent-bars-mode)
    (should diff-hl-mode)
    (should display-line-numbers)
    (should (= company-idle-delay my-company-idle-delay))
    (should (memq #'format/initialize-on-first-save before-save-hook))))

(ert-deftest my-large-buffer-skips-language-server-start ()
  (with-temp-buffer
    (let ((my-large-buffer-threshold 32)
          (started 0))
      (insert (make-string 64 ?x))
      (setq major-mode 'python-mode)
      (cl-letf (((symbol-function 'lsp-deferred)
                 (lambda () (cl-incf started)))
                ((symbol-function 'executable-find) (lambda (_) "/bin/true")))
        (my-start-language-lsp)
        (my-typst-start-lsp))
      (should (zerop started)))))

(ert-deftest my-large-org-buffer-skips-decorations ()
  (with-temp-buffer
    (let ((my-large-buffer-threshold 32))
      (insert "* Heading\n" (make-string 64 ?x))
      (org-mode)
      (should-not (bound-and-true-p org-modern-mode)))))

(ert-deftest my-format-first-and-later-saves-run-once ()
  (let ((file (make-temp-file "emacs-format-test-" nil ".el"))
        (calls 0))
    (unwind-protect
        (with-current-buffer (find-file-noselect file)
          (insert "(defun performance-example (x)\n(+ x 1))\n")
          (require 'format-all)
          (let ((formatter (symbol-function 'format-all--buffer-from-hook)))
            (cl-letf (((symbol-function 'format-all--buffer-from-hook)
                       (lambda () (cl-incf calls) (funcall formatter))))
              (save-buffer)
              (should (= calls 1))
              (should format-all-mode)
              (should (equal (buffer-string)
                             "(defun performance-example (x)\n  (+ x 1))\n"))
              (goto-char (point-max))
              (insert ";; second save\n")
              (save-buffer)
              (should (= calls 2))))
          (kill-buffer))
      (when-let ((buffer (get-file-buffer file)))
        (with-current-buffer buffer (set-buffer-modified-p nil))
        (kill-buffer buffer))
      (delete-file file))))

(ert-deftest my-format-manual-disable-cancels-lazy-setup ()
  (with-temp-buffer
    (emacs-lisp-mode)
    (format-all-mode -1)
    (should-not (memq #'format/initialize-on-first-save before-save-hook))
    (should-not (memq #'format-all--buffer-from-hook before-save-hook))))

(ert-deftest my-format-skips-buffer-that-grew-before-first-save ()
  (with-temp-buffer
    (let ((my-large-buffer-threshold 32))
      (emacs-lisp-mode)
      (insert (make-string 64 ?x))
      (format/initialize-on-first-save)
      (should-not (bound-and-true-p format-all-mode)))))

(ert-deftest my-company-toggle-restores-configured-delay ()
  (with-temp-buffer
    (setq-local company-idle-delay my-company-idle-delay)
    (my/toggle-auto-completion)
    (should-not company-idle-delay)
    (my/toggle-auto-completion)
    (should (= company-idle-delay my-company-idle-delay))))

(ert-deftest my-snippet-collection-remains-available ()
  (with-temp-buffer
    (rename-buffer "snippet-regression" t)
    (emacs-lisp-mode)
    (should yas-minor-mode)
    (should (yas-lookup-snippet "defun" 'emacs-lisp-mode))))

;;; buffer-performance-tests.el ends here
