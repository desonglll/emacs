# Emacs configuration

A small, modular configuration using straight.el for package management.

## Structure

- `early-init.el`: startup and frame initialization.
- `init.el`: paths and module loading.
- `lisp/core-defaults.el`: encoding and general defaults.
- `lisp/core-packages.el`: straight.el bootstrap and use-package integration.
- `lisp/platform-macos.el`: modifier keys, shell environment, and frame focus.
- `lisp/core-ui.el`: minimal interface settings.
- `lisp/ui-appearance.el`: fonts, maximized frames, and theme.
- `lisp/core-editing.el`: editing behavior and key bindings.
- `lisp/core-state.el`: history, backups, and auto-save locations.
- `lisp/completion-minibuffer.el`: Vertico completion and Consult actions.
- `lisp/completion-buffer.el`: Corfu and Cape in-buffer completion.
- `lisp/tools-version-control.el`: Magit commands and bindings.
- `lisp/tools-lsp.el`: lsp-mode defaults.
- `lisp/tools-navigation.el`: Avy, Dirvish, Treemacs, and buffer navigation.
- `lisp/tools-productivity.el`: gptel and translation commands.
- `lisp/input-chinese.el`: Pyim with the basedict dictionary.
- `lisp/language-modes.el`: Just, Protobuf, and Typst modes.
- `lisp/keybindings.el`: personal global key bindings.
- `local.el`: optional machine-specific settings; ignored by Git.

Add future features as focused files under `lisp/`, then require them from
`init.el`.  Generated state is kept under `var/` and ignored by Git.

Declare packages with `use-package`; straight installs them automatically:

```elisp
(use-package example-package)
```

Run `M-x straight-freeze-versions` to write a reproducible package lockfile.

Start LSP in the current programming buffer with `M-x lsp`.  To enable it
automatically for a language, add a mode hook to `local.el`, for example:

```elisp
(add-hook 'python-ts-mode-hook #'lsp-deferred)
```

Typst support uses the `tinymist` language server and a compiled Tree-sitter
grammar.  The custom translation package uses the `trans` executable from
translate-shell.

## Key bindings

- `M-<f1>`: Magit status.
- `M-<f2>`: Dirvish.
- `C-:` or `s-\`: Avy jump.
- `M-#`: find files with Consult and fd.
- `C-c r`: search text with Consult and ripgrep.
- `s-i`: Imenu List.
- `s-e`: Treemacs.
- `M-o`: Ace Window.

On macOS, Command is Super and Option is Meta.
