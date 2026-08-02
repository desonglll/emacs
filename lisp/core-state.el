;;; core-state.el --- Persistent state and backups -*- lexical-binding: t; -*-

(defconst my-backup-directory
  (expand-file-name "backups/" my-state-directory))
(defconst my-auto-save-directory
  (expand-file-name "auto-save/" my-state-directory))

(make-directory my-backup-directory t)
(make-directory my-auto-save-directory t)

(setq backup-directory-alist `(("." . ,my-backup-directory))
      auto-save-file-name-transforms `((".*" ,my-auto-save-directory t))
      auto-save-list-file-prefix (expand-file-name "sessions/" my-auto-save-directory)
      backup-by-copying t
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t)

(setq savehist-file (expand-file-name "history" my-state-directory)
      save-place-file (expand-file-name "places" my-state-directory)
      recentf-save-file (expand-file-name "recentf" my-state-directory)
      recentf-max-saved-items 200
      history-length 500)

(savehist-mode 1)
(save-place-mode 1)
(recentf-mode 1)

(provide 'core-state)
;;; core-state.el ends here
