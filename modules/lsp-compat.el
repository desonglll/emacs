;;; lsp-compat.el --- Compatibility with installed language tools -*- lexical-binding: t; -*-

(defun my-typescript-server-path (path)
  "Use project PATH only when it includes the tsserver API.
TypeScript 7's native compiler does not provide that API; fall back to
the pinned TypeScript bundled with this configuration in that case."
  (if (and path (file-readable-p path)
           (or (not (file-directory-p path))
               (file-readable-p (expand-file-name "tsserver.js" path))))
      path
    (expand-file-name "node_modules/typescript/lib/tsserver.js"
                      my-language-tools-directory)))

(with-eval-after-load 'lsp-javascript
  (advice-add 'lsp-clients-typescript-server-path
              :filter-return #'my-typescript-server-path))

(defun my-volar-tsserver-request (workspace params)
  "Forward Volar requests, preserving the server's response envelope.
Volar 3.3 uses a flat vector; earlier versions use a nested vector."
  (let* ((nested (vectorp (aref params 0)))
         (request (if nested (aref params 0) params))
         (id (aref request 0))
         (reply (lambda (body)
                  (let ((payload (vector id body)))
                    (lsp-volar--send-notify
                     workspace "tsserver/response"
                     (if nested (vector payload) payload))))))
    (if-let ((typescript (lsp-find-workspace
                         lsp-volar-typescript-server-id
                         (lsp--workspace-root workspace))))
        (with-lsp-workspace typescript
          (lsp-request-async
           "workspace/executeCommand"
           (list :command "typescript.tsserverRequest"
                 :arguments (vector (aref request 1) (aref request 2)))
           (lambda (response) (funcall reply (lsp-get response :body)))
           :error-handler
           (lambda (err)
             (funcall reply nil)
             (lsp--warn "Vue TypeScript request failed: %S" err))))
      (funcall reply nil)
      (lsp--warn "Vue needs a running ts-ls workspace"))))

(with-eval-after-load 'lsp-volar
  (puthash "tsserver/request" #'my-volar-tsserver-request
           (lsp--client-notification-handlers
            (gethash 'vue-semantic-server lsp-clients))))

(provide 'my-lsp-compat)
;;; lsp-compat.el ends here
