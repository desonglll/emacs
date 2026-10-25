;;; language-tests.el --- Language and save-policy checks -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)
(require 'format-all)

(defmacro my-test-with-language-project (&rest body)
  "Run BODY in an isolated directory, closing its buffers afterwards."
  (declare (indent 0))
  `(let* ((directory (file-name-as-directory (make-temp-file "emacs-languages-" t)))
          (default-directory directory)
          (my-lsp-language-clients nil)
          (auto-mode-alist auto-mode-alist))
     (unwind-protect (progn ,@body)
       (dolist (buffer (buffer-list))
         (when-let ((file (buffer-file-name buffer)))
           (when (string-prefix-p directory file)
             (with-current-buffer buffer (set-buffer-modified-p nil))
             (kill-buffer buffer))))
       (delete-directory directory t))))

(defun my-test-language-file (name contents)
  "Write NAME with CONTENTS in the test project."
  (let ((file (expand-file-name name)))
    (make-directory (file-name-directory file) t)
    (with-temp-file file (insert contents))
    file))

(defconst my-test-language-cases
  '(("main.go" "package main\nfunc main() {}\n" go-ts-mode "Go" (gopls))
    ("main.zig" "pub fn main() void {}\n" zig-mode "Zig" (zls))
    ("build.zig.zon" ".{ .name = .example, .version = \"0.0.0\" }\n"
     zig-mode "Zig" (zls))
    ("Main.java" "class Main {}\n" java-ts-mode "Java" (jdtls))
    ("main.rs" "fn main() {}\n" rust-ts-mode "Rust" (rust-analyzer))
    ("main.c" "int main(void) { return 0; }\n" c-ts-mode "C" (clangd))
    ("main.cpp" "int main() { return 0; }\n" c++-ts-mode "C++" (clangd))
    ("main.js" "const count = 1;\n" js-ts-mode "JavaScript" (ts-ls))
    ("main.ts" "const count: number = 1;\n" typescript-ts-mode "TypeScript" (ts-ls))
    ("main.mts" "export const count = 1;\n" typescript-ts-mode "TypeScript" (ts-ls))
    ("main.tsx" "const app = <div />;\n" tsx-ts-mode "TSX" (ts-ls))
    ("App.vue" "<script setup lang=\"ts\">const count = 1;</script>\n<template>{{ count }}</template>\n"
     web-mode "Vue" (ts-ls vue-semantic-server))
    ("config.yaml" "name: example\n" yaml-ts-mode "YAML" (yamlls))
    ("config.toml" "name = \"example\"\n" toml-ts-mode "TOML" (taplo))
    ("script.sh" "#!/bin/bash\necho hello\n" bash-ts-mode "Shell" (bash-ls))))

(ert-deftest my-language-files-select-modes-and-formatters ()
  (my-test-with-language-project
    (dolist (entry my-test-language-cases)
      (pcase-let ((`(,name ,source ,mode ,language ,_) entry))
        (with-current-buffer (find-file-noselect (my-test-language-file name source))
          (ert-info ((format "File: %s" name))
            (should (eq major-mode mode))
            (should (equal (format-all--language-id-buffer) language))
            (should display-line-numbers-mode)
            (should (or (memq #'format/initialize-on-first-save before-save-hook)
                        (memq #'format/lsp-before-save before-save-hook)))
            (unless (format/use-lsp-p)
              (should (cl-every #'format/formatter-available-p
                                (format-all--get-chain language))))))))))

(ert-deftest my-language-routing-selects-only-the-intended-clients ()
  (let ((clients my-lsp-language-clients))
    (my-test-with-language-project
      (cl-letf (((symbol-function 'lsp-deferred) #'ignore))
        (let ((my-lsp-language-clients clients))
          (dolist (entry my-test-language-cases)
            (with-current-buffer
                (find-file-noselect (my-test-language-file (car entry) (cadr entry)))
              (ert-info ((format "File: %s" (car entry)))
                (should (equal lsp-enabled-clients (nth 4 entry)))
                (should (eq lsp-inlay-hint-enable
                            (eq (alist-get major-mode clients) 'lsp-rust)))
                (dolist (server lsp-enabled-clients)
                  (should (gethash server lsp-clients)))))))))))

(ert-deftest my-language-file-visits-resolve-true-paths ()
  (my-test-with-language-project
    (let* ((real-directory (expand-file-name "real" default-directory))
           (alias-directory (expand-file-name "alias" default-directory))
           (real-file (expand-file-name "main.rs" real-directory))
           (alias-file (expand-file-name "main.rs" alias-directory)))
      (make-directory real-directory)
      (make-symbolic-link real-directory alias-directory)
      (with-temp-file real-file (insert "fn main() {}\n"))
      (with-current-buffer (find-file-noselect alias-file)
        (should (equal buffer-file-name (file-truename real-file)))))))

(ert-deftest my-rust-tree-sitter-mode-retains-cargo-commands ()
  (my-test-with-language-project
    (let ((manifest (my-test-language-file
                     "Cargo.toml"
                     "[package]\nname = \"example\"\nversion = \"0.1.0\"\n"))
          (bindings '(("C-c C-c C-u" . rust-compile)
                      ("C-c C-c C-k" . rust-check)
                      ("C-c C-c C-t" . rust-test)
                      ("C-c C-c C-r" . rust-run)
                      ("C-c C-c C-l" . rust-run-clippy))))
      (with-current-buffer
          (find-file-noselect (my-test-language-file "src/main.rs" "fn main() {}\n"))
        (should (eq major-mode 'rust-ts-mode))
        (dolist (binding bindings)
          (should (commandp (cdr binding)))
          (should (eq (key-binding (kbd (car binding))) (cdr binding))))
        (let (actual-command actual-directory)
          (setq-local rust-buffer-project nil)
          (cl-letf (((symbol-function 'rust-buffer-project)
                     (lambda () manifest))
                    ((symbol-function 'compile)
                     (lambda (command &optional _comint)
                       (setq actual-command command
                             actual-directory default-directory))))
            (rust-check))
          (should (equal (string-trim actual-command) "cargo check"))
          (should (equal actual-directory directory)))))))

(ert-deftest my-rust-compilation-output-supports-error-navigation ()
  (require 'rust-ts-mode)
  (should (memq 'rustc compilation-error-regexp-alist))
  (with-temp-buffer
    (compilation-mode)
    (let ((inhibit-read-only t))
      (insert "error[E0277]: example\n  --> src/main.rs:49:10\n")
      (compilation--parse-region (point-min) (point-max)))
    (goto-char (point-min))
    (search-forward "src/main.rs")
    (should (get-text-property (1- (point)) 'compilation-message))))

(ert-deftest my-prose-layout-and-markdown-hard-breaks ()
  (my-test-with-language-project
    (with-current-buffer (find-file-noselect
                          (my-test-language-file "notes.md" "First line  \nSecond line\n"))
      (should visual-line-mode)
      (should-not display-line-numbers-mode)
      (set-buffer-modified-p t)
      (save-buffer)
      (should (string-match-p "First line  \nSecond line" (buffer-string))))))

(ert-deftest my-editorconfig-controls-indentation-and-whitespace ()
  (my-test-with-language-project
    (my-test-language-file ".editorconfig"
                           "root = true\n[*]\nindent_style = space\nindent_size = 3\ntab_width = 3\ntrim_trailing_whitespace = true\n[*.md]\ntrim_trailing_whitespace = false\n")
    (with-current-buffer (find-file-noselect (my-test-language-file "main.c" "int main(void) {}\n"))
      (should (= c-ts-mode-indent-offset 3)))
    (with-current-buffer (find-file-noselect (my-test-language-file "note.txt" "text  \n"))
      (should (= tab-width 3))
      (set-buffer-modified-p t)
      (save-buffer)
      (should (equal (buffer-string) "text\n")))
    (with-current-buffer (find-file-noselect (my-test-language-file "note.md" "text  \nnext\n"))
      (set-buffer-modified-p t)
      (save-buffer)
      (should (string-match-p "text  \nnext" (buffer-string))))))

(ert-deftest my-formatters-honor-project-settings-on-save ()
  (my-test-with-language-project
    (my-test-language-file ".clang-format" "BasedOnStyle: LLVM\nIndentWidth: 4\nAllowShortFunctionsOnASingleLine: None\n")
    (my-test-language-file ".prettierrc.json" "{\"singleQuote\": true, \"tabWidth\": 4}")
    (my-test-language-file ".editorconfig" "root = true\n[*.sh]\nindent_style = space\nindent_size = 4\n")
    (dolist (entry '(("main.c" "int main(){\nreturn 0;\n}\n" "    return 0;")
                     ("main.zig" "pub fn main() void {\nconst count:u8=1;\n_ = count;\n}\n"
                      "    const count: u8 = 1;")
                     ("build.zig.zon" ".{.name=.example,.version=\"0.0.0\"}\n"
                      ".{ .name = .example, .version = \"0.0.0\" }")
                     ("main.ts" "function greet(){\nconsole.log(\"hello\")\n}\n" "    console.log('hello');")
                     ("main.sh" "#!/bin/bash\nif true; then\necho hello\nfi\n" "    echo hello")
                     ("main.toml" "name=\"test\"\n" "name = \"test\"")))
      (with-current-buffer (find-file-noselect (my-test-language-file (car entry) (cadr entry)))
        (set-buffer-modified-p t)
        (save-buffer)
        (ert-info ((format "Formatter for %s" (car entry)))
          (should (string-match-p (regexp-quote (nth 2 entry)) (buffer-string))))))))

(ert-deftest my-formatters-use-project-executable-on-first-and-later-saves ()
  (my-test-with-language-project
    (let* ((fallback (executable-find "prettier"))
           (local (my-test-language-file
                   "node_modules/.bin/prettier"
                   (format "#!/bin/sh\nexec %s --single-quote \"$@\"\n"
                           (shell-quote-argument fallback)))))
      (set-file-modes local #o755)
      (with-current-buffer (find-file-noselect (my-test-language-file "main.js" "const x=\"hi\"\n"))
        (dotimes (_ 2)
          (erase-buffer)
          (insert "const x=\"hi\"\n")
          (save-buffer)
          (should (equal (buffer-string) "const x = 'hi';\n")))))))

(ert-deftest my-typescript-falls-back-when-project-has-no-tsserver ()
  (require 'lsp-javascript)
  (my-test-with-language-project
    (should (file-readable-p (my-typescript-server-path directory)))
    (let ((server (my-test-language-file "tsserver.js" "// test server")))
      (should (equal (my-typescript-server-path directory) directory))
      (should (equal (my-typescript-server-path server) server)))))

(ert-deftest my-volar-forwards-flat-and-nested-protocol-messages ()
  (require 'lsp-volar)
  (let ((workspace (make-lsp--workspace :root "/tmp/vue-project/"))
        (body (ht ("value" 123)))
        (request (vector 7 "quickinfo" (ht ("file" "App.vue"))))
        actual)
    (cl-letf (((symbol-function 'lsp-find-workspace)
               (lambda (server root)
                 (should (eq server 'ts-ls))
                 (should (equal root "/tmp/vue-project/"))
                 workspace))
              ((symbol-function 'lsp-request-async)
               (lambda (method params callback &rest _)
                 (should (equal method "workspace/executeCommand"))
                 (should (equal (plist-get params :command) "typescript.tsserverRequest"))
                 (should (equal (plist-get params :arguments)
                                (vector (aref request 1) (aref request 2))))
                 (funcall callback (ht ("body" body)))))
              ((symbol-function 'lsp-volar--send-notify)
               (lambda (target method params)
                 (should (eq target workspace))
                 (should (equal method "tsserver/response"))
                 (setq actual params))))
      (my-volar-tsserver-request workspace request)
      (should (equal actual (vector 7 body)))
      (my-volar-tsserver-request workspace (vector request))
      (should (equal actual (vector (vector 7 body)))))))

(provide 'my-language-tests)
;;; language-tests.el ends here
