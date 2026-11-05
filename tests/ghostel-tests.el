;;; ghostel-tests.el --- Real Ghostel terminal checks -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)
(require 'ibuffer)
(require 'ghostel)

(defun my-ghostel-test-await (predicate)
  "Process terminal output for up to ten seconds until PREDICATE succeeds."
  (let ((deadline (+ (float-time) 10)))
    (while (and (not (funcall predicate)) (< (float-time) deadline))
      (accept-process-output nil 0.05)
      (ghostel-force-redraw))
    (should (funcall predicate))))

(defmacro my-ghostel-test-sandbox (&rest body)
  "Run BODY in a disposable local terminal, without user shell startup files."
  (declare (indent 0))
  `(let* ((directory (file-name-as-directory
                      (file-truename (make-temp-file "emacs-ghostel-" t))))
          (default-directory directory)
          (process-environment (cons (concat "ZDOTDIR=" directory) process-environment))
          (ghostel-shell '("/bin/zsh" "-f"))
          (ghostel-macos-login-shell nil)
          (ghostel-shell-integration nil)
          (ghostel-buffer-name (generate-new-buffer-name "*ghostel-test*"))
          (ghostel-kill-buffer-on-exit nil)
          (before (ghostel-buffer-list)))
     (unwind-protect
         (save-window-excursion ,@body)
       (dolist (buffer (seq-difference (ghostel-buffer-list) before))
         (when (buffer-live-p buffer)
           (with-current-buffer buffer
             (let ((process ghostel--process))
               (when (processp process)
                 (set-process-query-on-exit-flag process nil))
               (let ((kill-buffer-query-functions nil)) (kill-buffer buffer))
               ;; Native children finish asynchronously and zsh writes its
               ;; history on exit.  Wait before removing their working dir.
               (let ((deadline (+ (float-time) 5)))
                 (while (and (process-live-p process) (< (float-time) deadline))
                   (accept-process-output process 0.05)))
               (when (process-live-p process) (delete-process process))))))
       (delete-directory directory t))))

(ert-deftest my-ghostel-native-terminal-renders-output-and-copies-without-input ()
  (my-ghostel-test-sandbox
    (let ((kill-ring nil)
          (interprogram-cut-function nil)
          (select-enable-clipboard nil))
      (call-interactively (key-binding (kbd "C-c t g")))
      (should (derived-mode-p 'ghostel-mode))
      (should (featurep 'ghostel-module))
      (should (process-live-p ghostel--process))
      (should-not display-line-numbers-mode)
      (should-not global-hl-line-mode)
      (should-not company-idle-delay)
      (should (= line-spacing 0))
      (should (eq (key-binding (kbd "C-c t g")) #'ghostel))
      (should (eq (key-binding (kbd "C-c t t")) #'my-terminal-toggle))
      (ghostel-send-string "printf '\\033[31mGHOSTEL_%s\\033[0m\\n' 'READY'\n")
      ;; The command itself does not contain the contiguous result string.
      (my-ghostel-test-await (lambda () (string-match-p "GHOSTEL_READY" (buffer-string))))
      (ghostel-copy-mode)
      (goto-char (point-min))
      (search-forward "GHOSTEL_READY")
      (let ((start (- (point) (length "GHOSTEL_READY"))))
        (should (get-text-property start 'face))
        (set-mark start)
        (activate-mark)
        (cl-letf (((symbol-function 'ghostel-send-string)
                   (lambda (&rest _) (ert-fail "Copy sent terminal input"))))
          (call-interactively (key-binding (kbd "s-c"))))
        (should (equal (substring-no-properties (car kill-ring)) "GHOSTEL_READY")))
      (should (string-prefix-p "Terminal" (my-ui-frame-title)))
      (should (ibuffer-included-in-filters-p
               (current-buffer)
               (cdr (assoc "Terminals" (my-ibuffer-project-groups))))))))

(ert-deftest my-ghostel-shell-integration-tracks-the-working-directory ()
  (my-ghostel-test-sandbox
    (let ((ghostel-shell "/bin/zsh")
          (ghostel-shell-integration t)
          (child (expand-file-name "child/" directory)))
      (make-directory child)
      (ghostel)
      (ghostel-send-string (format "cd %s\n" (shell-quote-argument child)))
      (my-ghostel-test-await
       (lambda () (equal (file-name-as-directory (file-truename default-directory))
                         child))))))

;;; ghostel-tests.el ends here
