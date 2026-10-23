;;; packages.el --- Central package declarations -*- lexical-binding: t; -*-

(setq straight-base-dir my-data-directory
      straight-profiles
      `((nil . ,(expand-file-name "straight-versions.el"
                                  my-config-directory)))
      straight-recipe-overrides nil)

;; Track package edits on save instead of scanning every checkout at startup.
;; External edits can be detected with `straight-check-all'.
(setq straight-check-for-modifications '(check-on-save find-when-checking))

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)
(require 'use-package)

;; Work around a case-sensitive filename collision in the ELPA mirror.
(straight-override-recipe
 '(xr :type git :host github :repo "mattiase/xr"))

;; Files under plugins/ configure packages; they never install implicitly.
(setq straight-use-package-by-default nil
      use-package-always-defer t)

(defmacro my-use-package! (name &rest arguments)
  "Configure the declared package NAME with use-package ARGUMENTS."
  (declare (indent 1))
  `(use-package ,name
     :straight nil
     ,@arguments))

(defmacro package! (name &rest recipe)
  "Install NAME through straight.el, optionally using RECIPE."
  (declare (indent 1))
  `(straight-use-package
    ',(if recipe (cons name recipe) name)))

;;;; User interface

;; Emacs 30's Org satisfies org-modern; keep using the bundled version.
(package! org :type built-in)
(package! gruber-darker-theme)
(package! dirvish)
(package! imenu-list)
(package! treemacs)
(package! nerd-icons)
(package! nerd-icons-completion)
(package! doom-modeline)
(package! indent-bars)
(package! pulsar)
(package! org-modern)
(package! helpful)

;;;; Completion

(package! vertico)
(package! orderless)
(package! marginalia)
(package! consult)
(package! embark)
(package! embark-consult)
(package! wgrep)
;; (package! corfu)
(package! company)
(package! cape)
(package! prescient)
(package! company-prescient)
(package! vertico-prescient)

;;;; Editing

(package! yasnippet)
(package! yasnippet-snippets)
(package! expreg)
(package! multiple-cursors)
(package! vundo)
(package! iedit)
(package! hl-todo)
(package! ace-window)
(package! avy)
(package! translate
  :type git :host github
  :repo "desonglll/translate.el")
(package! pyim)
(package! pyim-basedict)
(package! pyim-tsinghua-dict
  :type git
  :host github
  :repo "redguardtoo/pyim-tsinghua-dict")

;;;; Development

(package! exec-path-from-shell)
(package! envrc)
(package! eat
  :type git :host codeberg :repo "akib/emacs-eat"
  :local-repo "eat"
  :files ("*.el" ("term" "term/*.el") "*.texi" "*.ti"
          ("terminfo/e" "terminfo/e/*")
          ("terminfo/65" "terminfo/65/*")
          ("integration" "integration/*")
          (:exclude ".dir-locals.el" "*-tests.el")))
(package! verb)
(package! magit)
(package! lsp-mode)
(package! rust-mode)
(package! go-mode)
(package! zig-mode)
(package! swift-mode)
(package! swift-ts-mode)
(package! lsp-java)
(package! lsp-pyright)
(package! lsp-sourcekit)
(package! just-mode)
(package! web-mode)
(package! typescript-mode)
(package! yaml-mode)
(package! toml-mode)
(package! protobuf-mode
  :type git :host github :repo "protocolbuffers/protobuf"
  :depth 1 :files ("editors/protobuf-mode.el"))
(package! typst-ts-mode
  :type git :host codeberg
  :repo "meow_king/typst-ts-mode")

(package! format-all)
(package! pdf-tools)
(package! projectile)
(package! perspective)
(package! diff-hl)

;;;; AI

(package! gptel)
(package!
    '(gptel-autocomplete :type git :host github :repo "JDNdeveloper/gptel-autocomplete"))

(provide 'packages)
;;; packages.el ends here
