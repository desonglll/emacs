;;; editing-tests.el --- Structural editing checks -*- lexical-binding: t; -*-

(require 'ert)
(require 'multiple-cursors)

(ert-deftest my-multiple-cursors-bindings-and-state-location ()
  (dolist (binding '(("C->" . mc/mark-next-like-this)
                     ("C-<" . mc/mark-previous-like-this)
                     ("C-c m a" . mc/mark-all-like-this)
                     ("C-c m l" . mc/edit-lines)))
    (should (eq (key-binding (kbd (car binding))) (cdr binding))))
  (should (string-prefix-p (file-name-as-directory my-state-directory)
                           mc/list-file)))

(ert-deftest my-multiple-cursors-marks-the-next-occurrence ()
  (with-temp-buffer
    (insert "item item item")
    (goto-char (point-min))
    (let ((transient-mark-mode t))
      (push-mark (+ (point) (length "item")) t t)
      (mc/mark-next-like-this 1)
      (should multiple-cursors-mode)
      (should (= (mc/num-cursors) 2))
      (multiple-cursors-mode 0))))

;;; editing-tests.el ends here
