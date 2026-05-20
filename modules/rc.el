(defun rc/copy-current-file-path ()
  "copy current file path"
  (interactive)
  (if (buffer-file-name)
      (progn
        (kill-new (buffer-file-name))
        (message "copyed absouletly path: %s" (buffer-file-name)))
    (message "no file provided!")))


(provide 'rc)
