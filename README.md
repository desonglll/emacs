# Emacs configuration

A small, Doom-style configuration using straight.el for package management.

## Structure

- `early-init.el`: startup and frame initialization.
- `init.el`: state paths and deterministic load order.
- `packages.el`: the only file that installs straight.el packages.
- `plugins/`: automatically loaded third-party package configuration, grouped by
  feature with complex packages in dedicated files.
- `straight-versions.el`: reproducible straight.el package revisions.
- `config.el`: native Emacs behavior, state, macOS, fonts, and Tree-sitter.
- `modules/rc.el`: personal interactive commands.
- `modules/keymaps.el`: global key bindings.
- `local.el`: optional machine-specific settings; ignored by Git.

The hand-written configuration lives in `~/.config/emacs`.  Downloaded
packages, Tree-sitter grammars, native compilation output, and generated state
live under `~/.emacs.d`; persistent state is grouped in `~/.emacs.d/var`.

Because Emacs prefers an existing `~/.emacs.d` over the XDG configuration
directory, these startup links connect the data directory to this repository:

```sh
ln -s ../.config/emacs/early-init.el ~/.emacs.d/early-init.el
ln -s ../.config/emacs/init.el ~/.emacs.d/init.el
```

Declare every new package in `packages.el`:

```elisp
(package! example-package)
```

Use an explicit recipe for a package from a specific Git repository:

```elisp
(package! example-package
  :type git :host github :repo "owner/repository")
```

Configure packages in a suitable file under `plugins/` with `my-use-package!`.
Files are loaded automatically in filename order.  This macro always sets
`:straight nil`, so package configuration cannot install packages:

```elisp
(my-use-package! example-package
  :commands example-command)
```

Run `M-x straight-freeze-versions` after changing packages to update the
reproducible lockfile.

LSP starts automatically for Rust, C, C++, Java, Python, Go, and Swift. The
configuration uses these language servers:

- Rust: `rust-analyzer`
- C and C++: `clangd`
- Java: `jdtls` through `lsp-java`
- Python: `pyright` through `lsp-pyright`
- Go: `gopls`
- Swift: Xcode's `sourcekit-lsp` through `lsp-sourcekit`

Install those executables with the system package manager so they are on
`PATH`.  On macOS with Homebrew, `jdtls` and `pyright` can be installed with:

```sh
brew install jdtls pyright
```

Run `M-x my-install-language-grammars` once to install the pinned grammars for
all 25 file-editing Tree-sitter modes bundled with Emacs 30.2, plus Swift and
Typst.
PHPDoc and JSDoc are included because Emacs' PHP mode requires them. All parser
revisions use ABI 14, matching this Emacs build. Until the required grammars are
available, existing major-mode associations stay unchanged. Add grammar sources
and mode mappings in `config.el`; add LSP clients in `plugins/lsp.el` when the
language should start LSP automatically.

Typst support uses the `tinymist` language server and a compiled Tree-sitter
grammar.  The custom translation package uses the `trans` executable from
translate-shell.

Swift support requires Xcode or a Swift toolchain containing `sourcekit-lsp`.
Optional format-on-save support uses SwiftFormat (`brew install swiftformat`).

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
