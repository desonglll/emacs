;;; ui.el --- User interface package configuration -*- lexical-binding: t; -*-

(my-use-package! gruber-darker-theme
  :demand t
  :config
  (mapc #'disable-theme custom-enabled-themes)
  (load-theme 'gruber-darker t))

(my-use-package! dirvish
  :commands dirvish)

(my-use-package! imenu-list
  :commands imenu-list)

(my-use-package! treemacs
  :commands treemacs)

(provide 'my-ui)
;;; ui.el ends here
