;;; language-server-tests.el --- Real server smoke checks -*- lexical-binding: t; -*-

;; Explicit opt-in: these checks start the installed servers in tiny temporary
;; projects.  No user project is opened or built.  Load language-tests.el first.
(require 'my-language-tests)
(require 'lsp-mode)
(dolist (client '(lsp-java lsp-rust lsp-zig lsp-yaml lsp-toml))
  (require client))

(defun my-test-await (predicate seconds)
  "Wait up to SECONDS for PREDICATE while processing server output."
  (let ((deadline (+ (float-time) seconds)))
    (while (and (not (funcall predicate)) (< (float-time) deadline))
      (accept-process-output nil 0.1))
    (funcall predicate)))

(defconst my-test-server-cases
  '(("main.go" "package main\nfunc main() { var count int = \"wrong\"; println(count) }\n" (gopls))
    ("main.zig" "pub fn main() void { const count = ; }\n" (zls))
    ("Main.java" "class Main { int count = \"wrong\"; }\n" (jdtls))
    ("src/main.rs" "async fn task(){}\nfn main(){let count: i32 = \"wrong\"; println!(\"{}\",count);}\n" (rust-analyzer))
    ("main.c" "int main(void) { return missing; }\n" (clangd))
    ("main.cpp" "int main() { return missing; }\n" (clangd))
    ("main.js" "// @ts-check\nfunction greet() { return missing; }\n" (ts-ls))
    ("main.ts" "const count: number = \"wrong\";\n" (ts-ls))
    ("main.tsx" "const count: number = \"wrong\";\nconst app = <div>{count}</div>;\n" (ts-ls))
    ("App.vue" "<script setup lang=\"ts\">\nconst count: number = \"wrong\";\n</script>\n<template><div>{{ count }}</div></template>\n" (ts-ls vue-semantic-server))
    ("config.yaml" "name: test\nname: duplicate\n" (yamlls))
    ("config.toml" "name = \"test\"\nname = \"duplicate\"\n" (taplo))
    ("script.sh" "#!/bin/bash\necho $undefined_value\n" (bash-ls))))

(defun my-test-live-language-server (entry)
  "Check startup, symbol requests, diagnostics and formatting for ENTRY."
  (let ((clients my-lsp-language-clients))
    (my-test-with-language-project
      (make-directory ".git")
      (when (string-suffix-p ".java" (car entry))
        (my-test-language-file ".project"
                               "<projectDescription><name>smoke</name><buildSpec><buildCommand><name>org.eclipse.jdt.core.javabuilder</name></buildCommand></buildSpec><natures><nature>org.eclipse.jdt.core.javanature</nature></natures></projectDescription>")
        (my-test-language-file ".classpath"
                               "<classpath><classpathentry kind=\"src\" path=\"\"/><classpathentry kind=\"con\" path=\"org.eclipse.jdt.launching.JRE_CONTAINER\"/><classpathentry kind=\"output\" path=\"bin\"/></classpath>"))
      (my-test-language-file "go.mod" "module example.test/smoke\n\ngo 1.23\n")
      (my-test-language-file "Cargo.toml"
                             "[package]\nname = \"smoke\"\nversion = \"0.1.0\"\nedition = \"2024\"\n")
      (my-test-language-file "tsconfig.json"
                             "{\"compilerOptions\":{\"strict\":true,\"target\":\"ESNext\",\"module\":\"ESNext\",\"moduleResolution\":\"bundler\",\"jsx\":\"preserve\",\"allowJs\":true,\"checkJs\":true},\"include\":[\"**/*\"]}")
      (let* ((lsp--session nil)
             (lsp-session-file (expand-file-name "lsp-session"))
             ;; Eclipse refuses projects containing its own workspace data.
             (lsp-java-workspace-dir (make-temp-file "emacs-jdtls-" t))
             (lsp-java-workspace-cache-dir (expand-file-name "cache/" lsp-java-workspace-dir))
             (lsp-auto-guess-root t)
             (lsp-enable-file-watchers nil)
             (lsp-enable-on-type-formatting nil)
             (lsp-restart 'ignore)
             (lsp-response-timeout 30)
             (lsp-yaml-schema-store-enable nil)
             (lsp-toml-schema-catalogs [])
             (file (my-test-language-file (car entry) (cadr entry)))
             (buffer (find-file-noselect file)))
        (unwind-protect
            (save-window-excursion
              (switch-to-buffer buffer)
              (let ((my-lsp-language-clients clients))
                (cl-letf (((symbol-function 'lsp-deferred) #'ignore))
                  (my-start-language-lsp)))
              (lsp)
              (should (my-test-await
                       (lambda ()
                         (cl-every
                          (lambda (id)
                            (seq-some
                             (lambda (workspace)
                               (and (eq id (lsp--client-server-id (lsp--workspace-client workspace)))
                                    (eq (lsp--workspace-status workspace) 'initialized)))
                             (lsp-workspaces)))
                          (nth 2 entry)))
                       90))
              (when (derived-mode-p 'rust-ts-mode)
                (should lsp-inlay-hints-mode))
              (should (lsp-feature? "textDocument/documentSymbol"))
              (let ((symbols (lsp-request "textDocument/documentSymbol"
                                          (list :textDocument (lsp--text-document-identifier)))))
                (message "SMOKE %s symbols=%s" (car entry) (length symbols)))
              (should (my-test-await
                       (lambda () (gethash (file-truename file) (lsp-diagnostics))) 40))
              (message "SMOKE %s diagnostics=%s" (car entry)
                       (length (gethash (file-truename file) (lsp-diagnostics))))
              (when (format/use-lsp-p)
                (let ((before (buffer-string)))
                  (format/lsp-before-save)
                  (should-not (equal before (buffer-string)))
                  (when (derived-mode-p 'rust-ts-mode)
                    (should (string-match-p "async fn task()" (buffer-string)))))))
          (with-current-buffer buffer
            (dolist (workspace (lsp-workspaces))
              (lsp-workspace-shutdown workspace))
            (set-buffer-modified-p nil)
            (kill-buffer buffer))
          (delete-directory lsp-java-workspace-dir t))))))

(dolist (entry my-test-server-cases)
  (eval `(ert-deftest ,(intern (concat "my-live-server-" (car entry))) ()
           (my-test-live-language-server ',entry))))

;;; language-server-tests.el ends here
