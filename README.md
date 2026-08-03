# Emacs configuration

A small, Doom-style configuration using straight.el for package management.

## Structure

- `early-init.el`: startup and frame initialization.
- `init.el`: state paths and deterministic load order.
- `packages.el`: the only file that installs straight.el packages.
- `config.el`: native Emacs behavior, UI, macOS, fonts, Tree-sitter, and keys.
- `modules/completion.el`: Vertico, Consult, Embark, Corfu, and Cape settings.
- `modules/tools.el`: Magit, LSP, navigation, AI, and translation settings.
- `modules/languages.el`: Pyim, language modes, and language server settings.
- `local.el`: optional machine-specific settings; ignored by Git.

Generated state is kept under `var/` and ignored by Git.

Declare every new package in `packages.el`:

```elisp
(package! example-package)
```

Use an explicit recipe for a package from a specific Git repository:

```elisp
(package! example-package
  :type git :host github :repo "owner/repository")
```

Configure the package in the relevant module with `my-use-package!`.  This
macro always sets `:straight nil`, so modules cannot install packages:

```elisp
(my-use-package! example-package
  :commands example-command)
```

Run `M-x straight-freeze-versions` after changing packages to update the
reproducible lockfile.

LSP starts automatically for Rust, C, C++, Java, Python, and Go.  The
configuration uses these language servers:

- Rust: `rust-analyzer`
- C and C++: `clangd`
- Java: `jdtls` through `lsp-java`
- Python: `pyright` through `lsp-pyright`
- Go: `gopls`

Install those executables with the system package manager so they are on
`PATH`.  On macOS with Homebrew, `jdtls` and `pyright` can be installed with:

```sh
brew install jdtls pyright
```

Run `M-x my-install-language-grammars` once to install the C, C++, Go, Java,
Python, and Rust Tree-sitter grammars.  Until a grammar is available, the
configuration falls back to the traditional major mode.  Add a language to
`my-treesit-language-sources`, `my-treesit-mode-remaps`, and
`my-lsp-language-clients` to extend the same setup.

Typst support uses the `tinymist` language server and a compiled Tree-sitter
grammar.  The custom translation package uses the `trans` executable from
translate-shell.

Nerd Icons is declared in `packages.el`.  Run `M-x nerd-icons-install-fonts`
once to install its symbol font.

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
