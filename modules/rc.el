;;; rc.el --- my custom functions -*- lexical-binding: t; -*-

(defun my/current-buffer ()
  (interactive)
  (message "current buffer: %s" buffer-file-name)
  )

(defun my/new-buffer ()
  "Create a new buffer in the selected window."
  (interactive)
  (let ((buffer (generate-new-buffer "*new*")))
    (set-window-buffer nil buffer)
    (with-current-buffer buffer
      (funcall (default-value 'major-mode)))))

(defun my/open-config ()
  "Recursively find and open an Emacs Lisp configuration file."
  (interactive)
  (let* ((config-dir (expand-file-name "~/.config/emacs/"))
         (files
          (mapcar
           (lambda (file)
             (file-relative-name file config-dir))
           (directory-files-recursively
            config-dir
            "\\.el\\'"
            nil
            (lambda (dir)
              (not (string=(file-name-nondirectory (directory-file-name dir)) "straight"))))))
         (selected
          (completing-read "Open file: " files nil t)))
    (find-file (expand-file-name selected config-dir))))

(defun my/kill-other-buffers (&optional arg)
  "Kill other unmodified buffers.

With prefix argument FORCE, also include internal buffers and ask
before killing modified buffers."
  (interactive "P")
  (let ((current-buffer (current-buffer))
        (killed-count 0))
    (dolist (buffer (buffer-list))
      (unless (eq buffer current-buffer)
        (let ((name (buffer-name buffer)))
          (when (and name
                     (or arg
                         (not (string-prefix-p " " name)))
                     (or (not (buffer-modified-p buffer))
                         (if arg
                             (y-or-n-p
                              (format "Kill modified buffer `%s'? " name))
                           )
                         ))
            (when (kill-buffer buffer)
              (setq killed-count (1+ killed-count)))))))
    (message "Killed %d buffer%s"
             killed-count
             (if (= killed-count 1) "" "s"))))

(defun my/list-buffers-focus (arg)
  "List buffers and focus."
  (interactive "P")
  (list-buffers)
  (pop-to-buffer "*Buffer List*")
  (if arg
      (delete-other-windows)
    )
  )

(defun my/upper-case-region (beg end)
  (interactive "r")
  (message "selected region: %s" (buffer-substring beg end))
  (upcase-region beg end)
  )

(defun fd-cd (&optional choose-root)
  "Use fd to select a directory and set `default-directory'.

With a prefix argument, prompt for the directory from which fd
should start searching."
  (interactive "P")
  (unless (executable-find "fd")
    (user-error "Cannot find the fd executable"))

  (let* ((root
          (file-name-as-directory
           (expand-file-name
            (if choose-root
                (read-directory-name
                 "Search from: "
                 (expand-file-name "~/"))
              default-directory))))
         (dirs
          (with-temp-buffer
            (unless (zerop
                     (process-file
                      "fd" nil t nil
                      "--type" "d"
                      "--hidden"
                      "--exclude" ".git"
                      "--absolute-path"
                      "--print0"
                      "." root))
              (user-error "fd failed: %s"
                          (string-trim (buffer-string))))

            ;; fd does not include the search root in its output.
            (cons root
                  (split-string (buffer-string) "\0" t))))
         (dir
          (completing-read
           "Change directory: "
           dirs nil t)))

    (setq default-directory
          (file-name-as-directory dir))
    (message "Directory: %s" default-directory)))

(defun my/toggle-auto-completion()
  (interactive)
  (if company-idle-delay
      (setq company-idle-delay nil)
    (setq company-idle-delay 0.01)
    )
  )

(defun my/user-buffer-p (buffer)
  (with-current-buffer buffer
    (and
     (not (string-match-p "\\`[ *]" (buffer-name buffer)))
     (not (derived-mode-p 'magit-mode))
     (not (derived-mode-p
           'help-mode
           'completion-list-mode
           'special-mode))
     ))
  )

(defun my/change-buffer(&optional arg)
  (interactive "P")
  (let* ((buffers
          (if arg
              (buffer-list)
            (seq-filter #'my/user-buffer-p (buffer-list))
            ))
         (names (mapcar #'buffer-name buffers))
         (selected (completing-read "change to:" names nil t)))
    (switch-to-buffer selected)
    ))



;;; rc.el ends here.
