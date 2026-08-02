;;; tools-productivity.el --- AI and translation tools -*- lexical-binding: t; -*-

(use-package gptel
  :commands (gptel gptel-send gptel-menu))

(use-package translate
  :straight
  (translate
   :type git
   :host github
   :repo "desonglll/translate.el")
  :commands (translate-trans translate-argo))

(provide 'tools-productivity)
;;; tools-productivity.el ends here
