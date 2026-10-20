;;; directory-search.el --- Asynchronous directory selection -*- lexical-binding: t; -*-

(defvar consult-fd-args)
(defvar my-directory-history nil)

(defun fd-cd (&optional choose-root)
  "Search directories asynchronously with fd and change `default-directory'.
With prefix CHOOSE-ROOT, prompt for the search root.  The root itself is
available before typing; further results arrive as the search runs."
  (interactive "P")
  (unless (executable-find "fd") (user-error "Cannot find the fd executable"))
  (require 'consult)
  (let* ((root (file-name-as-directory
                (expand-file-name
                 (if choose-root (read-directory-name "Search from: " "~/")
                   default-directory))))
         (directory
          (let ((default-directory root)
                (consult-fd-args '("fd" "--color=never" "--full-path" "--type=d"
                                  "--hidden" "--exclude=.git" "--absolute-path")))
            (consult--read
             (consult--async-merge
              (list (consult--async-static (list root))
                    (consult--process-collection (consult--fd-make-builder '("."))
                      :min-input 1 :highlight t :file-handler t)))
             :prompt "Change directory: " :category 'file :sort nil
             :require-match t :default root
             :history '(:input my-directory-history)))))
    (unless (file-directory-p directory)
      (user-error "Directory no longer exists: %s" directory))
    (setq default-directory (file-name-as-directory directory))
    (message "Directory: %s" default-directory)))

(provide 'my-directory-search)
;;; directory-search.el ends here
