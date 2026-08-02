# Emacs configuration

A small, modular configuration using straight.el for package management.

## Structure

- `early-init.el`: startup and frame initialization.
- `init.el`: paths and module loading.
- `lisp/config-packages.el`: straight.el bootstrap and shared Git recipes.
- `lisp/config-core.el`: defaults, editing, state, macOS, fonts, and theme.
- `lisp/config-completion.el`: minibuffer and in-buffer completion.
- `lisp/config-tools.el`: Git, LSP, navigation, AI, and translation tools.
- `lisp/config-languages.el`: Pyim and additional language modes.
- `lisp/config-keybindings.el`: personal global key bindings.
- `local.el`: optional machine-specific settings; ignored by Git.

Add future features as focused files under `lisp/`, then require them from
`init.el`.  Generated state is kept under `var/` and ignored by Git.

Declare packages with `use-package`; straight installs them automatically:

```elisp
(use-package example-package)
```

For a package from a specific Git repository, use the shared helper:

```elisp
(my-use-git-package example-package github
  "owner/repository"
  :commands example-command)
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
