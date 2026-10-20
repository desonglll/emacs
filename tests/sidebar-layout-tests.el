;;; sidebar-layout-tests.el --- Sidebar resizing behavior -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)
(require 'imenu-list)

(ert-deftest my-sidebar-follows-frame-size-and-preserves-manual-window-size ()
  (let ((buffer (generate-new-buffer " *sidebar-layout*"))
        (width (frame-width))
        (old-width (frame-parameter nil 'my-sidebar-frame-width)))
    (unwind-protect
        (save-window-excursion
          (delete-other-windows)
          (let* ((editor (selected-window))
                 (sidebar (display-buffer-in-side-window
                           buffer '((side . left) (window-width . 32)))))
            (with-current-buffer buffer
              (setq major-mode 'treemacs-mode)
              (setq-local window-size-fixed 'width))
            (set-frame-parameter nil 'my-sidebar-frame-width nil)
            (my-sidebar-resize-with-frame (selected-frame))
            (should (= (window-total-width sidebar) (my-sidebar-width)))
            (should (eq (selected-window) editor))
            (with-current-buffer buffer
              (let ((window-size-fixed nil)) (window-resize sidebar 3 t)))
            (let ((manual-width (window-total-width sidebar)))
              (my-sidebar-resize-with-frame (selected-frame))
              (should (= manual-width (window-total-width sidebar))))
            (cl-letf (((symbol-function 'frame-width) (lambda (&optional _) (+ width 40))))
              (my-sidebar-resize-with-frame (selected-frame))
              (should (= (window-total-width sidebar) (my-sidebar-width))))
            (should (eq (selected-window) editor))))
      (set-frame-parameter nil 'my-sidebar-frame-width old-width)
      (kill-buffer buffer))))

(ert-deftest my-sidebar-imenu-opens-at-responsive-width ()
  (let ((buffer (generate-new-buffer " *outline-layout*")))
    (unwind-protect
        (save-window-excursion
          (delete-other-windows)
          (let ((window (imenu-list-display-buffer buffer nil)))
            (should (window-live-p window))
            (should (= (window-total-width window) (my-sidebar-width)))))
      (kill-buffer buffer))))

;;; sidebar-layout-tests.el ends here
