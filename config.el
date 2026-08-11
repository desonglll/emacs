;;; config.el --- Native Emacs configuration -*- lexical-binding: t; -*-

;;;; Defaults

(setq inhibit-startup-screen t
      inhibit-startup-message t
      initial-scratch-message nil
      ring-bell-function #'ignore
      use-short-answers t
      confirm-kill-emacs #'yes-or-no-p
      sentence-end-double-space nil
      require-final-newline t
      ;; tab-always-indent 'complete
      read-process-output-max (* 1024 1024))

(set-language-environment "UTF-8")
(prefer-coding-system 'utf-8-unix)
(set-default-coding-systems 'utf-8-unix)

(setq-default indent-tabs-mode nil
              tab-width 4
              fill-column 80
              truncate-lines nil)

;;;; Interface

(setq frame-title-format '("%b - GNU Emacs on Mike Shinoda")
      icon-title-format frame-title-format
      visible-bell nil
      cursor-in-non-selected-windows nil)

(column-number-mode 1)
(global-display-line-numbers-mode 1)
(global-hl-line-mode 1)
(show-paren-mode 1)

(defun my-disable-line-numbers ()
  "Disable line numbers in the current non-source buffer."
  (display-line-numbers-mode -1))

(dolist (hook '(eshell-mode-hook
                shell-mode-hook
                term-mode-hook
                vterm-mode-hook
                help-mode-hook
                special-mode-hook))
  (add-hook hook #'my-disable-line-numbers))

;;;; Editing

(delete-selection-mode 1)
(electric-pair-mode 1)
(global-auto-revert-mode 1)
(global-so-long-mode 1)

(setq auto-revert-verbose nil
      global-auto-revert-non-file-buffers t
      kill-do-not-save-duplicates t
      save-interprogram-paste-before-kill t
      scroll-conservatively 101
      mouse-wheel-progressive-speed nil)

(defun my-delete-trailing-whitespace ()
  "Delete trailing whitespace in programming and text buffers."
  (when (derived-mode-p 'prog-mode 'text-mode)
    (delete-trailing-whitespace)))

(add-hook 'before-save-hook #'my-delete-trailing-whitespace)
(keymap-global-set "C-c w" #'whitespace-mode)

;;;; Persistent state

(defconst my-backup-directory
  (expand-file-name "backups/" my-state-directory))
(defconst my-auto-save-directory
  (expand-file-name "auto-save/" my-state-directory))

(make-directory my-backup-directory t)
(make-directory my-auto-save-directory t)

(setq backup-directory-alist `(("." . ,my-backup-directory))
      auto-save-file-name-transforms `((".*" ,my-auto-save-directory t))
      auto-save-list-file-prefix
      (expand-file-name "sessions/" my-auto-save-directory)
      backup-by-copying t
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t
      savehist-file (expand-file-name "history" my-state-directory)
      save-place-file (expand-file-name "places" my-state-directory)
      recentf-save-file (expand-file-name "recentf" my-state-directory)
      recentf-max-saved-items 200
      history-length 500)

(savehist-mode 1)
(save-place-mode 1)
(recentf-mode 1)

;;;; macOS

(when (eq system-type 'darwin)
  (setq mac-command-modifier 'super
        mac-option-modifier 'meta
        ns-command-modifier 'super
        ns-alternate-modifier 'meta
        ns-option-modifier 'meta))

(defun my-focus-initial-frame ()
  "Give the initial graphical frame keyboard focus."
  (when (display-graphic-p)
    (select-frame-set-input-focus (selected-frame))))

(add-hook 'emacs-startup-hook #'my-focus-initial-frame)

;;;; Appearance

(defconst my-latin-font
  (font-spec :family "Iosevka Term SS15" :size 16 :weight 'regular))
(defconst my-cjk-font
  (font-spec :family "Sarasa Term SC"))
(defconst my-serif-font
  (font-spec :family "Iosevka Curly Slab" :size 16 :weight 'regular))

;; (add-to-list 'default-frame-alist '(font . "Iosevka Term SS15"))

(defun my-set-cjk-font (&optional frame)
  "Use Sarasa Term SC for CJK characters in FRAME."
  (let ((frame (or frame (selected-frame))))
    (when (and (display-graphic-p frame)
               (find-font my-cjk-font frame))
      (dolist (charset '(han kana cjk-misc bopomofo))
        (set-fontset-font nil charset my-cjk-font frame 'prepend)))))

(defun my-apply-fonts (&optional frame)
  "Apply the configured Latin and CJK fonts to FRAME."
  (let ((frame (or frame (selected-frame))))
    (when (and (display-graphic-p frame)
               (find-font my-latin-font frame))
      (dolist (face '(default fixed-pitch variable-pitch))
        (set-face-attribute face frame
                            :family "Iosevka Term SS15"
                            :height 160
                            :weight 'regular))
      (my-set-cjk-font frame))))

(add-hook 'Info-mode-hook
          (lambda ()
            (message "invoke!!!")
            (face-remap-add-relative 'default :family "Iosevka Curly Slab" :height 160 :weight 'regular)))

(add-hook 'after-setting-font-hook #'my-set-cjk-font)
(add-hook 'after-make-frame-functions #'my-apply-fonts)
(add-hook 'emacs-startup-hook #'my-apply-fonts)

;;;; Tree-sitter

(require 'treesit)

(defconst my-treesit-language-sources
  '((bash "https://github.com/tree-sitter/tree-sitter-bash" "v0.23.3" "src")
    (c "https://github.com/tree-sitter/tree-sitter-c" "v0.23.6" "src")
    (cmake "https://github.com/uyha/tree-sitter-cmake" "v0.7.4" "src")
    (cpp "https://github.com/tree-sitter/tree-sitter-cpp" "v0.22.0" "src")
    (c-sharp "https://github.com/tree-sitter/tree-sitter-c-sharp"
             "v0.23.1" "src")
    (css "https://github.com/tree-sitter/tree-sitter-css" "v0.23.2" "src")
    (dockerfile "https://github.com/camdencheek/tree-sitter-dockerfile"
                "v0.2.0" "src")
    (elixir "https://github.com/elixir-lang/tree-sitter-elixir"
            "v0.3.5" "src")
    (go "https://github.com/tree-sitter/tree-sitter-go" "v0.23.4" "src")
    (gomod "https://github.com/camdencheek/tree-sitter-go-mod"
           "v1.1.0" "src")
    (heex "https://github.com/phoenixframework/tree-sitter-heex"
          "v0.8.1" "src")
    (html "https://github.com/tree-sitter/tree-sitter-html" "v0.23.2" "src")
    (java "https://github.com/tree-sitter/tree-sitter-java" "v0.23.5" "src")
    (javascript "https://github.com/tree-sitter/tree-sitter-javascript"
                "v0.23.1" "src")
    (jsdoc "https://github.com/tree-sitter/tree-sitter-jsdoc"
           "v0.23.2" "src")
    (json "https://github.com/tree-sitter/tree-sitter-json" "v0.24.8" "src")
    (lua "https://github.com/tree-sitter-grammars/tree-sitter-lua"
         "v0.3.0" "src")
    (php "https://github.com/tree-sitter/tree-sitter-php"
         "v0.23.12" "php/src")
    (phpdoc "https://github.com/claytonrcarter/tree-sitter-phpdoc"
            "v0.1.6" "src")
    (python "https://github.com/tree-sitter/tree-sitter-python"
            "v0.23.6" "src")
    (ruby "https://github.com/tree-sitter/tree-sitter-ruby" "v0.23.1" "src")
    (rust "https://github.com/tree-sitter/tree-sitter-rust" "v0.23.3"
          "src")
    (swift "https://github.com/alex-pinkus/tree-sitter-swift"
           "0.7.3-with-generated-files" "src")
    (toml "https://github.com/tree-sitter-grammars/tree-sitter-toml"
          "v0.7.0" "src")
    (typescript "https://github.com/tree-sitter/tree-sitter-typescript"
                "v0.23.2" "typescript/src")
    (tsx "https://github.com/tree-sitter/tree-sitter-typescript"
         "v0.23.2" "tsx/src")
    (typst "https://github.com/uben0/tree-sitter-typst" "v0.11.0" "src")
    (yaml "https://github.com/tree-sitter-grammars/tree-sitter-yaml"
          "v0.7.2" "src"))
  "Pinned Tree-sitter grammars used by the configured language modes.")

(defconst my-treesit-mode-remaps
  '(((bash) sh-mode bash-ts-mode)
    ((c cpp) c-or-c++-mode c-or-c++-ts-mode)
    ((c) c-mode c-ts-mode)
    ((cpp) c++-mode c++-ts-mode)
    ((c-sharp) csharp-mode csharp-ts-mode)
    ((css) css-mode css-ts-mode)
    ((go) go-mode go-ts-mode)
    ((java) java-mode java-ts-mode)
    ((python) python-mode python-ts-mode)
    ((ruby) ruby-mode ruby-ts-mode)
    ((rust) rust-mode rust-ts-mode)
    ((swift) swift-mode swift-ts-mode))
  "Mappings from traditional modes to Tree-sitter modes.")

(defconst my-treesit-file-modes
  '(((cmake) ("\\(?:CMakeLists\\.txt\\|\\.cmake\\)\\'") cmake-ts-mode)
    ((dockerfile)
     ("\\(?:Dockerfile\\(?:\\..*\\)?\\|\\.[Dd]ockerfile\\)\\'")
     dockerfile-ts-mode)
    ((elixir) ("\\.elixir\\'" "\\.exs?\\'" "mix\\.lock\\'") elixir-ts-mode)
    ((gomod) ("/go\\.mod\\'") go-mod-ts-mode)
    ((heex) ("\\.[hl]?eex\\'") heex-ts-mode)
    ((html) ("\\.html\\'") html-ts-mode)
    ((javascript) ("\\.\\(?:[cm]?js\\|jsx\\)\\'") js-ts-mode)
    ((json) ("\\.json\\'") json-ts-mode)
    ((lua) ("\\.lua\\'") lua-ts-mode)
    ((php phpdoc html javascript jsdoc css)
     ("\\.\\(?:php[s345]?\\|phtml\\|inc\\|stub\\)\\'"
      "/\\.php_cs\\(?:\\.dist\\)?\\'")
     php-ts-mode)
    ((toml) ("\\.toml\\'") toml-ts-mode)
    ((typescript) ("\\.ts\\'") typescript-ts-mode)
    ((tsx) ("\\.tsx\\'") tsx-ts-mode)
    ((yaml) ("\\.ya?ml\\'") yaml-ts-mode))
  "File patterns for modes that require an installed Tree-sitter grammar.")

(dolist (source my-treesit-language-sources)
  (setf (alist-get (car source) treesit-language-source-alist)
        (cdr source)))

(defun my-refresh-treesit-mode-remaps ()
  "Prefer Tree-sitter modes for grammars that are installed."
  (dolist (mapping my-treesit-mode-remaps)
    (pcase-let ((`(,languages ,base-mode ,treesit-mode) mapping))
      (setq major-mode-remap-alist
            (delete (cons base-mode treesit-mode) major-mode-remap-alist))
      (when (and (fboundp treesit-mode)
                 (treesit-ready-p languages t))
        (setf (alist-get base-mode major-mode-remap-alist)
              treesit-mode))))
  (dolist (mapping my-treesit-file-modes)
    (pcase-let ((`(,languages ,patterns ,treesit-mode) mapping))
      (let ((ready (and (fboundp treesit-mode)
                        (treesit-ready-p languages t))))
        (dolist (pattern patterns)
          (setq auto-mode-alist
                (delete (cons pattern treesit-mode) auto-mode-alist))
          (when ready
            (add-to-list 'auto-mode-alist (cons pattern treesit-mode))))))))

(defun my-install-language-grammars ()
  "Install missing Tree-sitter grammars used by this configuration."
  (interactive)
  (unless (treesit-available-p)
    (user-error "This Emacs build has no Tree-sitter support"))
  (let (failed-languages)
    (dolist (source my-treesit-language-sources)
      (let ((language (car source)))
        (unless (treesit-language-available-p language)
          (message "Installing the %s Tree-sitter grammar..." language)
          (treesit-install-language-grammar language))
        (unless (treesit-language-available-p language)
          (push language failed-languages))))
    (my-refresh-treesit-mode-remaps)
    (if failed-languages
        (user-error "Tree-sitter grammars failed: %s"
                    (mapconcat #'symbol-name
                               (nreverse failed-languages) ", "))
      (message "Configured Tree-sitter grammars are installed"))))

(my-refresh-treesit-mode-remaps)

(provide 'config)
;;; config.el ends here
