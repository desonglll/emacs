;;; marksman-tests.el --- Markdown and Flycheck integration -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)
(require 'lsp-mode)
(require 'lsp-diagnostics)
(require 'flycheck)

(defun my-marksman-test-await (predicate)
  "Process server output for up to 20 seconds until PREDICATE succeeds."
  (let ((deadline (+ (float-time) 20)))
    (while (and (not (funcall predicate)) (< (float-time) deadline))
      (accept-process-output nil 0.1))
    (funcall predicate)))

(ert-deftest my-flycheck-configuration-and-automatic-checking-policy ()
  (should (eq lsp-diagnostics-provider :flycheck))
  (should (eq (key-binding (kbd "M-g f")) #'consult-flycheck))
  (should (eq (key-binding (kbd "C-c d b")) #'my-flycheck-show-errors))
  (should (eq (key-binding (kbd "C-c d p")) #'my-flycheck-show-project-errors))
  (with-temp-buffer
    (let ((my-large-buffer-threshold 32)
          (enabled 0))
      (cl-letf (((symbol-function 'flycheck-mode)
                 (lambda (_) (cl-incf enabled)))
                ((symbol-function 'flycheck-may-enable-mode) (lambda () t)))
        (setq buffer-file-name "/tmp/notes.md" major-mode 'markdown-mode)
        (my-enable-file-flycheck)
        (should (zerop enabled))
        (setq buffer-file-name "/ssh:example.invalid:/tmp/file.el"
              major-mode 'emacs-lisp-mode)
        (my-enable-file-flycheck)
        (should (zerop enabled))
        (setq buffer-file-name "/tmp/file.el")
        (insert (make-string 64 ?x))
        (my-enable-file-flycheck)
        (should (zerop enabled))
        (erase-buffer)
        (my-enable-file-flycheck)
        (should (= enabled 1))))))

(ert-deftest my-flycheck-replaces-flymake-and-preserves-the-bottom-panel ()
  (let ((flycheck-check-syntax-automatically nil))
    (with-temp-buffer
      (emacs-lisp-mode)
      (flymake-mode 1)
      (flycheck-mode 1)
      (should-not flymake-mode)
      (unwind-protect
          (save-window-excursion
            (switch-to-buffer (current-buffer))
            (my-flycheck-show-project-errors)
            (with-current-buffer flycheck-error-list-buffer
              (should (eq flycheck-error-list-scope 'project)))
            (should (eq (window-parameter
                         (get-buffer-window flycheck-error-list-buffer) 'window-side)
                        'bottom))
            (my-flycheck-show-errors)
            (with-current-buffer flycheck-error-list-buffer
              (should (eq flycheck-error-list-scope 'buffer))))
        (flycheck-mode -1)
        (when-let ((buffer (get-buffer flycheck-error-list-buffer)))
          (kill-buffer buffer))))))

(ert-deftest my-marksman-marker-identifies-a-project-without-git ()
  (let* ((directory (file-name-as-directory
                     (file-truename (make-temp-file "emacs-notes-" t))))
         (nested (expand-file-name "notes/subdirectory/" directory)))
    (unwind-protect
        (progn
          (make-directory nested t)
          (with-temp-file (expand-file-name ".marksman.toml" directory))
          (should (equal (project-root (project-current nil nested)) directory)))
      (delete-directory directory t))))

(ert-deftest my-marksman-live-links-completion-and-flycheck-diagnostics ()
  (should (executable-find "marksman"))
  (let* ((directory (file-name-as-directory
                     (file-truename (make-temp-file "emacs-marksman-" t))))
         (default-directory directory)
         (file (expand-file-name "a.md" directory))
         (target (expand-file-name "b.md" directory))
         (lsp--session nil)
         (lsp-session-file (expand-file-name "lsp-session" directory))
         (lsp-auto-guess-root t)
         (lsp-enable-file-watchers nil)
         (lsp-restart 'ignore)
         (lsp-response-timeout 20)
         buffer)
    (unwind-protect
        (progn
          (with-temp-file ".marksman.toml")
          (with-temp-file target (insert "# Beta\n"))
          (with-temp-file file
            (insert "# Alpha\n\n[Jump](b.md#beta)\n\n[[missing-note]]\n\n[[Be]]\n"))
          (setq buffer (find-file-noselect file))
          (save-window-excursion
            (switch-to-buffer buffer)
            (should (eq major-mode 'markdown-mode))
            (should visual-line-mode)
            (should-not display-line-numbers-mode)
            (should (equal lsp-enabled-clients '(marksman)))
            (lsp)
            (should (my-marksman-test-await
                     (lambda ()
                       (seq-some
                        (lambda (workspace)
                          (eq (lsp--workspace-status workspace) 'initialized))
                        (lsp-workspaces)))))
            (should flycheck-mode)
            (should (eq flycheck-checker 'lsp))
            (should-not (bound-and-true-p flymake-mode))
            (goto-char (point-min))
            (search-forward "b.md")
            (backward-char 2)
            (let ((definitions (lsp-request "textDocument/definition"
                                            (lsp--text-document-position-params))))
              (should (equal (lsp:location-uri
                              (if (lsp-location? definitions)
                                  definitions
                                (elt definitions 0)))
                             (lsp--path-to-uri target))))
            (goto-char (point-min))
            (search-forward "[[Be")
            (let* ((response (lsp-request "textDocument/completion"
                                          (lsp--text-document-position-params)))
                   (items (if (lsp-completion-list? response)
                              (lsp:completion-list-items response)
                            response)))
              (should (seq-some
                       (lambda (item)
                         (string-match-p "[Bb]eta" (lsp:completion-item-label item)))
                       items)))
            (should (my-marksman-test-await
                     (lambda () (gethash file (lsp-diagnostics)))))
            (flycheck-buffer)
            (should (my-marksman-test-await (lambda () flycheck-current-errors)))
            (should flycheck-annotate-mode)
            (let ((original (buffer-string)))
              (goto-char (point-min))
              (search-forward "[[missing-note]]")
              (flycheck-annotate--refresh)
              (should
               (seq-some
                (lambda (overlay)
                  (let ((text (overlay-get overlay 'display)))
                    (and (stringp text) (string-match-p "missing-note" text))))
                flycheck-annotate--overlays))
              (goto-char (point-min))
              (flycheck-annotate--refresh)
              (should
               (seq-some
                (lambda (overlay)
                  (let ((text (overlay-get overlay 'before-string)))
                    (and (stringp text) (string-match-p "missing-note" text))))
                flycheck-annotate--overlays))
              (should (equal (buffer-string) original)))
            (my-flycheck-show-project-errors)
            (with-current-buffer flycheck-error-list-buffer
              (should (flycheck-error-list-current-errors)))
            (message "MARKSMAN: cross-file definition, completion and %d Flycheck diagnostics"
                     (length flycheck-current-errors))))
      (when (buffer-live-p buffer)
        (with-current-buffer buffer
          (dolist (workspace (lsp-workspaces))
            (lsp-workspace-shutdown workspace))
          (set-buffer-modified-p nil)
          (kill-buffer buffer)))
      (when-let ((errors (get-buffer flycheck-error-list-buffer)))
        (kill-buffer errors))
      (delete-directory directory t))))

;;; marksman-tests.el ends here
