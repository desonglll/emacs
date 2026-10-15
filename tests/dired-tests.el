;;; dired-tests.el --- Directory Git indicator checks -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)
(require 'dired)
(require 'dirvish)

(defun my-dired-test-write (file text)
  (make-directory (file-name-directory file) t)
  (with-temp-file file (insert text)))

(defun my-dired-test-git (&rest args)
  (should (zerop (apply #'call-process "git" nil nil nil args))))

(defun my-dired-test-commit ()
  (my-dired-test-git "add" "-A")
  (my-dired-test-git "-c" "user.name=Emacs Test"
                     "-c" "user.email=test@example.invalid"
                     "-c" "commit.gpgsign=false" "-c" "core.hooksPath=/dev/null"
                     "commit" "-qm" "Test fixture"))

(defun my-dired-test-wait ()
  (let ((deadline (+ (float-time) 5)))
    (while (and (buffer-live-p diff-hl-dired-process-buffer)
                (< (float-time) deadline))
      (accept-process-output nil 0.05))
    (should-not (buffer-live-p diff-hl-dired-process-buffer))))

(defun my-dired-test-type (file)
  (save-excursion
    (should (dired-goto-file (expand-file-name file)))
    (cl-loop for overlay in (overlays-in (line-beginning-position)
                                         (line-end-position))
             thereis (overlay-get overlay 'diff-hl-dired-type))))

(defmacro my-dired-test-repository (&rest body)
  (declare (indent 0))
  `(let* ((directory (make-temp-file "emacs-dired-test-" t))
          (default-directory (file-name-as-directory directory))
          (existing-buffers (buffer-list)))
     (unwind-protect
         (save-window-excursion
           (my-dired-test-git "init" "-q")
           (dolist (file '("modified.txt" "clean.txt" "src/deep/file.txt"
                           "removed/gone.txt"))
             (my-dired-test-write (expand-file-name file) "original\n"))
           (my-dired-test-write (expand-file-name ".gitignore") "cache/\n")
           (my-dired-test-commit)
           ,@body)
       (dolist (buffer (cl-set-difference (buffer-list) existing-buffers))
         (when (buffer-live-p buffer)
           (with-current-buffer buffer
             (when-let ((process (get-buffer-process buffer)))
               (set-process-query-on-exit-flag process nil)
               (set-process-sentinel process #'ignore)
               (delete-process process))
             (set-buffer-modified-p nil)
             (let ((kill-buffer-query-functions nil)) (kill-buffer buffer)))))
       (delete-directory directory t))))

(ert-deftest my-dired-git-indicators-aggregate-and-refresh ()
  (my-dired-test-repository
    (dolist (file '("modified.txt" "src/deep/file.txt" "added.txt"
                    "new.txt" "new-dir/new.txt" "cache/ignored.txt"))
      (my-dired-test-write (expand-file-name file) "changed\n"))
    (delete-file (expand-file-name "removed/gone.txt"))
    (my-dired-test-git "add" "added.txt")
    (switch-to-buffer (dired-noselect directory))
    (should diff-hl-dired-mode)
    (my-dired-test-wait)
    (dolist (entry '(("modified.txt" . change) ("src" . change)
                     ("added.txt" . insert) ("new.txt" . unknown)
                     ("new-dir" . unknown) ("removed" . delete)
                     ("clean.txt" . nil) ("cache" . nil)))
      (should (eq (my-dired-test-type (car entry)) (cdr entry))))
    (my-dired-test-commit)
    ;; Returning from a terminal/Magit should clear now-committed changes.
    (my-dired-git-refresh-visible (selected-window))
    (my-dired-test-wait)
    (should-not (my-dired-test-type "modified.txt"))
    (should-not (my-dired-test-type "src"))
    (let* ((listing (current-buffer))
           (file (find-file-noselect (expand-file-name "src/deep/file.txt"))))
      (with-current-buffer file
        (goto-char (point-max))
        (insert "saved in Emacs\n")
        (let ((before-save-hook nil)) (save-buffer)))
      (with-current-buffer listing
        (my-dired-test-wait)
        (should (eq (my-dired-test-type "src") 'change))))))

(ert-deftest my-dired-git-skips-remote-directories ()
  (with-temp-buffer
    (setq default-directory "/ssh:example.invalid:/repo/")
    (cl-letf (((symbol-function 'diff-hl-dired-mode)
               (lambda (&rest _) (ert-fail "Remote Git scan enabled"))))
      (my-dired-git-setup))))

(ert-deftest my-dired-git-survives-dirvish-render-and-revert ()
  (let ((override-active dirvish-override-dired-mode))
    (unwind-protect
        (progn
          (dirvish-override-dired-mode 1)
          (my-dired-test-repository
            (my-dired-test-write (expand-file-name "modified.txt") "changed\n")
            (let ((dirvish-default-layout nil))
              (dirvish directory)
              (select-window (selected-window)))
            (should (dirvish-curr))
            (let ((deadline (+ (float-time) 5)))
              (while (and (not (dirvish-prop :vc-backend))
                          (< (float-time) deadline))
                (accept-process-output nil 0.05))
              (should (dirvish-prop :vc-backend)))
            (my-dired-test-wait)
            (dirvish--render-attrs (selected-window))
            (should (eq (my-dired-test-type "modified.txt") 'change))
            (revert-buffer nil t)
            (my-dired-test-wait)
            (should (eq (my-dired-test-type "modified.txt") 'change))))
      (unless override-active (dirvish-override-dired-mode -1)))))

;;; dired-tests.el ends here
