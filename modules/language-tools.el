;;; language-tools.el --- Language tool discovery -*- lexical-binding: t; -*-

(defconst my-language-tools-directory
  (expand-file-name "language-tools/" my-state-directory)
  "Directory containing the pinned Node-based language tools.")

(dolist (directory (list (expand-file-name "node_modules/.bin" my-language-tools-directory)
                         (expand-file-name "~/.cargo/bin")
                         (expand-file-name "~/go/bin")))
  (when (file-directory-p directory)
    (add-to-list 'exec-path directory)
    (unless (member directory (parse-colon-path (getenv "PATH")))
      (setenv "PATH" (concat directory path-separator (getenv "PATH"))))))

(defconst my-language-client-tools
  '((lsp-clangd :servers (clangd) :commands ("clangd"))
    (lsp-go :servers (gopls) :commands ("gopls"))
    (lsp-java :servers (jdtls) :commands ("jdtls"))
    (lsp-rust :servers (rust-analyzer) :commands ("rust-analyzer"))
    (lsp-zig :servers (zls) :commands ("zls"))
    (lsp-lua :servers (lua-language-server) :commands ("lua-language-server"))
    (lsp-javascript :servers (ts-ls) :commands ("typescript-language-server"))
    (lsp-volar :servers (ts-ls vue-semantic-server)
               :commands ("typescript-language-server" "vue-language-server"))
    (lsp-yaml :servers (yamlls) :commands ("yaml-language-server"))
    (lsp-toml :servers (taplo) :commands ("taplo"))
    (lsp-bash :servers (bash-ls) :commands ("bash-language-server"))
    (lsp-marksman :servers (marksman) :commands ("marksman"))
    (lsp-pyright :servers (pyright) :commands ("pyright-langserver"))
    (lsp-sourcekit :servers (sourcekit-ls) :commands ("sourcekit-lsp")))
  "Preferred LSP servers and required executables for each client feature.")

(defun my-language-tools-check ()
  "Show the installed language servers and formatters."
  (interactive)
  (with-help-window "*Language Tools*"
    (princ "Language servers\n\n")
    (dolist (entry my-language-client-tools)
      (dolist (command (plist-get (cdr entry) :commands))
        (princ (format "%-28s %s\n" command
                       (or (executable-find command) "MISSING")))))
    (princ "\nFormatters and shell diagnostics\n\n")
    (dolist (command '("gofmt" "rustfmt" "zig" "clang-format" "prettier"
                       "black" "dockerfmt"
                       "taplo" "shfmt" "shellcheck"))
      (princ (format "%-28s %s\n" command
                     (or (executable-find command) "MISSING"))))
    (princ "\nPDF backend\n\n")
    (let ((backend (bound-and-true-p pdf-info-epdfinfo-program)))
      (princ (format "%-28s %s\n" "epdfinfo"
                     (if (and backend (file-executable-p backend))
                         backend "MISSING"))))
    (princ "\nJava and Rust formatting use LSP to honor project settings.\n")))

(provide 'my-language-tools)
;;; language-tools.el ends here
