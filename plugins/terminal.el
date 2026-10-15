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

(defun my-terminal-find-buffer (root)
  "Return the most recently used terminal belonging to ROOT."
  (seq-find (lambda (buffer)
              (with-current-buffer buffer
                (and (derived-mode-p 'eat-mode)
                     (equal my-terminal-project-root root))))
            (buffer-list)))

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
      (let* ((origin (if (derived-mode-p 'eat-mode)
                         (window-parameter (selected-window) 'my-terminal-origin)
                       (selected-window)))
             (default-directory root)
             (eat-buffer-name
              (if buffer (buffer-name buffer)
                (generate-new-buffer-name
                 (format "*eat:%s*"
                         (file-name-nondirectory (directory-file-name root))))))
             (display-buffer-overriding-action
              `((display-buffer-in-side-window)
                (side . bottom) (slot . 0)
                (window-height . ,my-terminal-panel-height)))
             (terminal (eat-other-window)))
        (with-current-buffer terminal
          (setq-local my-terminal-project-root root))
        (select-window (get-buffer-window terminal (selected-frame)))
        (set-window-parameter (selected-window) 'my-terminal-origin origin)))))

(defun my-terminal-buffer-setup ()
  "Keep the terminal grid free of editor overlays and automatic popups."
  (setq-local line-spacing nil
              global-hl-line-mode nil
              show-trailing-whitespace nil
              company-idle-delay nil)
  (hl-line-mode -1))

(my-use-package! eat
  :commands (eat eat-other-window eat-project)
  :bind ("C-c t t" . my-terminal-toggle)
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
  (keymap-set eat-mode-map "C-c t t" #'my-terminal-toggle))

(provide 'my-plugins-terminal)
;;; terminal.el ends here
