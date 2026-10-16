;;; terminal.el --- Project terminal panels -*- lexical-binding: t; -*-

(defvar my-terminal-panel-height 0.3
  "Fraction of the frame height used when opening a terminal panel.")

(defvar-local my-terminal-project-root nil
  "Project identity for this terminal, independent of shell directory changes.")

(defun my-terminal-prepare-terminfo ()
  "Build Eat's terminal descriptions for macOS's system ncurses once.
The bundled 32-bit entries cannot be read by Apple's older ncurses."
  (when (eq system-type 'darwin)
    (let* ((source (expand-file-name "eat.ti"
                                     (file-name-directory (locate-library "eat"))))
           (directory (expand-file-name "eat-terminfo/" my-state-directory))
           (entry (expand-file-name "65/eat-truecolor" directory)))
      (when (or (not (file-exists-p entry))
                (file-newer-than-file-p source entry))
        (make-directory directory t)
        (with-temp-buffer
          ;; Use Apple's compiler even when Homebrew ncurses is on PATH.
          (unless (eq 0 (call-process "/usr/bin/tic" nil t nil
                                     "-x" "-o" directory source))
            (error "Cannot compile Eat terminfo: %s" (buffer-string)))))
      (setq eat-term-terminfo-directory directory))))

(defun my-terminal-context-directory ()
  "Return a canonical project root, falling back to the current directory."
  (or my-terminal-project-root
      (let* ((project (project-current nil))
             (directory (if project (project-root project) default-directory)))
        (file-name-as-directory
         (if (file-remote-p directory)
             (expand-file-name directory)
           (file-truename directory))))))

(defun my-terminal-buffers (&optional root)
  "Return Eat sessions belonging to ROOT, or all sessions when ROOT is nil."
  (seq-filter (lambda (buffer)
                (with-current-buffer buffer
                  (and (derived-mode-p 'eat-mode)
                       (or (null root) (equal my-terminal-project-root root)))))
              (buffer-list)))

(defun my-terminal-find-buffer (root)
  "Return the most recently used live terminal belonging to ROOT."
  (seq-find (lambda (buffer)
              (when-let ((process (get-buffer-process buffer)))
                (process-live-p process)))
            (my-terminal-buffers root)))

(defun my-terminal-show (root &optional buffer)
  "Show BUFFER in the terminal panel, or start a new session at ROOT.
Displaying a finished session preserves its output without restarting it."
  (require 'eat)
  (let* ((origin (if (window-parameter nil 'window-side)
                     (or (window-parameter nil 'my-terminal-origin)
                         (get-mru-window nil nil t))
                   (selected-window)))
         (default-directory root)
         (eat-buffer-name
          (generate-new-buffer-name
           (format "*eat:%s*"
                   (file-name-nondirectory (directory-file-name root)))))
         (display-buffer-overriding-action
          `((display-buffer-in-side-window)
            (side . bottom) (slot . 0)
            (window-height . ,my-terminal-panel-height)))
         (terminal (if buffer
                       (progn (pop-to-buffer buffer) buffer)
                     (eat-other-window))))
    (with-current-buffer terminal
      (setq-local my-terminal-project-root root))
    (select-window (get-buffer-window terminal (selected-frame)))
    (set-window-parameter nil 'my-terminal-origin origin)
    terminal))

(defun my-terminal-toggle (&optional new-session)
  "Show or hide the current project's terminal panel.
With prefix NEW-SESSION, start another terminal in the same project."
  (interactive "P")
  (require 'eat)
  (let* ((root (my-terminal-context-directory))
         (buffer (unless new-session (my-terminal-find-buffer root)))
         (window (and buffer (get-buffer-window buffer (selected-frame)))))
    (if (and window (eq (window-parameter window 'window-side) 'bottom))
        (let ((origin (window-parameter window 'my-terminal-origin)))
          (delete-window window)
          (when (window-live-p origin) (select-window origin)))
      (my-terminal-show root buffer))))

(defun my-terminal-annotation (buffer)
  "Describe BUFFER's process state and current shell directory."
  (with-current-buffer buffer
    (let ((process (get-buffer-process buffer)))
      (format "  %-8s %s"
              (if process (process-status process) 'exited)
              (abbreviate-file-name default-directory)))))

(defun my-terminal-select (&optional all-projects)
  "Select a terminal from this project; with prefix ALL-PROJECTS, from all."
  (interactive "P")
  (let* ((root (my-terminal-context-directory))
         (buffers (my-terminal-buffers (unless all-projects root)))
         (candidates (mapcar (lambda (buffer) (cons (buffer-name buffer) buffer))
                             buffers)))
    (if (null candidates)
        (my-terminal-show root)
      (let* ((completion-extra-properties
              (list :annotation-function
                    (lambda (name)
                      (my-terminal-annotation (cdr (assoc name candidates))))))
             (name (completing-read (if all-projects "All terminals: "
                                      "Project terminal: ")
                                    candidates nil t nil nil (caar candidates)))
             (buffer (cdr (assoc name candidates))))
        (my-terminal-show (with-current-buffer buffer
                            (my-terminal-context-directory))
                          buffer)))))

(defun my-terminal-rename ()
  "Give the current terminal a recognizable name without changing its project."
  (interactive)
  (unless (derived-mode-p 'eat-mode) (user-error "Select a terminal first"))
  (let ((name (string-trim (read-string "Terminal name: "))))
    (when (string-empty-p name) (user-error "Terminal name cannot be empty"))
    (rename-buffer (format "*eat:%s*" name) t)))

(defun my-terminal-buffer-setup ()
  "Keep the terminal grid free of editor overlays and automatic popups."
  (setq-local line-spacing nil
              global-hl-line-mode nil
              show-trailing-whitespace nil
              company-idle-delay nil
              my-terminal-project-root (my-terminal-context-directory))
  (hl-line-mode -1))

(my-use-package! eat
  :commands (eat eat-other-window eat-project)
  :bind (("C-c t t" . my-terminal-toggle)
         ("C-c t s" . my-terminal-select)
         ("C-c t r" . my-terminal-rename))
  :hook (eat-mode . my-terminal-buffer-setup)
  :custom
  (eat-kill-buffer-on-exit nil)
  (eat-enable-directory-tracking t)
  (eat-enable-shell-prompt-annotation t)
  :config
  (my-terminal-prepare-terminfo)
  ;; M-w otherwise goes to the shell; Command-C must copy without interrupting.
  (dolist (map (list eat-mode-map eat-semi-char-mode-map))
    (keymap-set map "M-w" #'kill-ring-save)
    (keymap-set map "s-c" #'kill-ring-save))
  (keymap-set eat-semi-char-mode-map "s-v" #'eat-yank)
  ;; Keep the panel shortcut available while terminal input owns the keyboard.
  (keymap-set eat-mode-map "C-c t t" #'my-terminal-toggle)
  (keymap-set eat-mode-map "C-c t s" #'my-terminal-select)
  (keymap-set eat-mode-map "C-c t r" #'my-terminal-rename))

(provide 'my-plugins-terminal)
;;; terminal.el ends here
