;;; buffer-management-tests.el --- Safe cleanup and buffer grouping -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)
(require 'ibuffer)
(require 'ibuf-ext)

(ert-deftest my-buffer-cleanup-preserves-other-workspaces-and-jobs ()
  (let* ((original (persp-current-name))
         (one (make-temp-name "cleanup-one-"))
         (two (make-temp-name "cleanup-two-"))
         (buffers (mapcar #'generate-new-buffer
                          '("cleanup-current" "cleanup-target" "cleanup-other"
                            "cleanup-shared" "cleanup-modified" "cleanup-terminal"
                            "cleanup-job")))
         process)
    (unwind-protect
        (save-window-excursion
          (persp-switch two)
          (persp-add-buffer (nth 2 buffers))
          (persp-add-buffer (nth 3 buffers))
          (persp-switch one)
          (switch-to-buffer (car buffers))
          (dolist (index '(1 3 4 5 6)) (persp-add-buffer (nth index buffers)))
          (with-current-buffer (nth 4 buffers) (insert "unsaved work"))
          (with-current-buffer (nth 5 buffers) (setq major-mode 'eat-mode))
          (setq process (make-process :name "cleanup-job" :buffer (nth 6 buffers)
                                      :command '("cat") :connection-type 'pipe :noquery t))
          (my/kill-other-buffers)
          (should-not (buffer-live-p (nth 1 buffers)))
          (dolist (index '(0 2 3 4 5 6)) (should (buffer-live-p (nth index buffers))))
          (should (process-live-p process))
          (should-not (memq (nth 3 buffers) (persp-current-buffers)))
          (should (memq (nth 3 buffers) (persp-buffers (gethash two (perspectives-hash)))))
          ;; A prefix still cannot touch another workspace or a running process.
          (with-current-buffer (nth 4 buffers) (set-buffer-modified-p nil))
          (my/kill-other-buffers t)
          (should (buffer-live-p (nth 2 buffers)))
          (should (buffer-live-p (nth 5 buffers)))
          (should (process-live-p process)))
      (when (process-live-p process) (delete-process process))
      (persp-switch original)
      (dolist (name (list one two))
        (when (member name (persp-names)) (persp-kill name)))
      (dolist (buffer buffers)
        (when (buffer-live-p buffer)
          (with-current-buffer buffer (set-buffer-modified-p nil))
          (kill-buffer buffer))))))

(ert-deftest my-ibuffer-separates-projects-with-the-same-name-and-unsaved-files ()
  (let* ((directory (make-temp-file "ibuffer-projects-" t))
         (roots (mapcar (lambda (part) (expand-file-name part directory))
                       '("a/project/" "b/project/")))
         buffers)
    (unwind-protect
        (save-window-excursion
          (dolist (root roots)
            (make-directory root t)
            (let ((default-directory root))
              (should (zerop (call-process "git" nil nil nil "init" "-q")))
              (with-temp-file (expand-file-name "file.txt") (insert "saved\n"))
              (push (find-file-noselect (expand-file-name "file.txt")) buffers)))
          (with-current-buffer (car buffers) (insert "unsaved\n"))
          (my/list-buffers-focus)
          (should (derived-mode-p 'ibuffer-mode))
          (let ((groups (ibuffer-generate-filter-groups
                         (mapcar (lambda (buffer) (cons buffer ?\s)) buffers))))
            (should (assq (car buffers) (cdr (assoc "Unsaved files" groups))))
            (should (assq (cadr buffers) (cdr (assoc (file-truename (car roots)) groups))))
            (should-not (assq (car buffers) (cdr (assoc (file-truename (car roots)) groups)))))
          (should (equal (key-binding (kbd "C-x C-b")) #'my/list-buffers-focus)))
      (dolist (buffer buffers)
        (with-current-buffer buffer (set-buffer-modified-p nil))
        (kill-buffer buffer))
      (when-let ((buffer (get-buffer "*Ibuffer*"))) (kill-buffer buffer))
      (delete-directory directory t))))

(ert-deftest my-buffer-cleanup-prefix-respects-unsaved-non-file-buffer-refusal ()
  (let ((current (generate-new-buffer "cleanup-keep"))
        (modified (generate-new-buffer "cleanup-unsaved")))
    (unwind-protect
        (with-current-buffer current
          (with-current-buffer modified (insert "unsaved text"))
          (let ((persp-mode nil))
            (cl-letf (((symbol-function 'buffer-list) (lambda (&rest _) (list current modified)))
                      ((symbol-function 'y-or-n-p) (lambda (&rest _) nil)))
              (my/kill-other-buffers t)))
          (should (buffer-live-p modified))
          (should (buffer-modified-p modified)))
      (with-current-buffer modified (set-buffer-modified-p nil))
      (kill-buffer modified)
      (kill-buffer current))))

(ert-deftest my-ibuffer-grouping-does-not-probe-remote-projects ()
  (with-temp-buffer
    (setq default-directory "/ssh:example.invalid:/repo/"
          buffer-file-name "/ssh:example.invalid:/repo/file.txt")
    (let ((remote (current-buffer)))
      (cl-letf (((symbol-function 'buffer-list) (lambda (&rest _) (list remote)))
                ((symbol-function 'project-current)
                 (lambda (&rest _) (ert-fail "Probed a remote project"))))
        (let ((groups (my-ibuffer-project-groups)))
          (should (ibuffer-included-in-filters-p remote (cdr (assoc "Remote" groups)))))))))

;;; buffer-management-tests.el ends here
