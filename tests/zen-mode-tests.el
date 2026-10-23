;;; zen-mode-tests.el --- Distraction-free editing checks -*- lexical-binding: t; -*-

(require 'ert)
(require 'writeroom-mode)

(ert-deftest my-zen-mode-settings-and-binding ()
  (should (eq (key-binding (kbd "C-c t z")) #'writeroom-mode))
  (should (= writeroom-width 100))
  (should (eq writeroom-fullscreen-effect 'maximized))
  (should writeroom-restore-window-config)
  (should-not writeroom-mode-line)
  (should (memq #'my-writeroom-line-numbers writeroom-local-effects)))

(ert-deftest my-zen-mode-restores-buffer-appearance ()
  (with-temp-buffer
    (let ((writeroom-global-effects nil)
          (writeroom-maximize-window nil)
          (writeroom-restore-window-config nil)
          (original-mode-line mode-line-format))
      (display-line-numbers-mode 1)
      (unwind-protect
          (progn
            (writeroom-mode 1)
            (should writeroom-mode)
            (should visual-fill-column-mode)
            (should-not display-line-numbers-mode)
            (should-not mode-line-format))
        (writeroom-mode -1))
      (should display-line-numbers-mode)
      (should (equal mode-line-format original-mode-line)))))

;;; zen-mode-tests.el ends here
