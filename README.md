# Emacs configuration

A small, Doom-style configuration using straight.el for package management.

## Requirements

For macOS, install GNU ls or dir...

```shell
brew install coreutils
```

then config the dired to use GNU gls.

```elisp
(setq insert-directory-program "gls")
(setq dired-use-ls-dired t)
```

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

The hand-written configuration lives in `~/.config/emacs`. Downloaded
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
Files are loaded automatically in filename order. This macro always sets
`:straight nil`, so package configuration cannot install packages:

```elisp
(my-use-package! example-package
  :commands example-command)
```

Run `M-x straight-freeze-versions` after changing packages to update the
reproducible lockfile.

LSP starts automatically for Rust, C, C++, Java, Python, Go, Swift, Typst,
JavaScript, TypeScript, and TSX. The configuration uses these language servers:

- Rust: `rust-analyzer`
- C and C++: `clangd`
- Java: `jdtls` through `lsp-java`
- Python: `pyright` through `lsp-pyright`
- Go: `gopls`
- Swift: Xcode's `sourcekit-lsp` through `lsp-sourcekit`
- Typst: `tinymist`
- JavaScript, TypeScript, and TSX: `typescript-language-server` through
  `lsp-javascript`

Install those executables with the system package manager so they are on
`PATH`. On Arch Linux:

```sh
sudo pacman -S clang gopls jdtls pyright rust-analyzer tinymist \
  typescript typescript-language-server
```

When `jdtls` is available on `PATH`, this configuration reuses the
system-managed installation and disables `lsp-java`'s server downloader for that
client. This avoids the slow Eclipse download used by `M-x lsp-java-update-server`.
On macOS with Homebrew, install the language servers you use with:

```sh
brew install jdtls pyright rust-analyzer typescript-language-server
```

Use explicit LSP command settings when the language server should always come
from `PATH`:

```elisp
(with-eval-after-load 'lsp-java
  (setq lsp-java-jdt-ls-prefer-native-command t
        lsp-java-jdt-ls-command "jdtls"))

(with-eval-after-load 'lsp-go
  (setq lsp-go-gopls-prefer-native-command t
        lsp-go-gopls-command "gopls"))

(with-eval-after-load 'lsp-rust
  (setq lsp-rust-server 'rust-analyzer
        lsp-rust-analyzer-server-command '("rust-analyzer")))

(with-eval-after-load 'lsp-javascript
  (setq lsp-clients-typescript-tls-path "typescript-language-server"
        lsp-clients-typescript-server-args '("--stdio")
        lsp-clients-typescript-prefer-use-project-ts-server t))
```

Rust does not have a `prefer-native-command` setting; `lsp-rust` already uses
`rust-analyzer` by default, and `lsp-rust-analyzer-server-command` is the command
override. TypeScript and JavaScript use the `lsp-javascript` client and
`typescript-language-server`. They start automatically through these
`my-lsp-language-clients` entries in `plugins/lsp.el`:

```elisp
(js-mode . lsp-javascript)
(js-ts-mode . lsp-javascript)
(typescript-mode . lsp-javascript)
(typescript-ts-mode . lsp-javascript)
(tsx-ts-mode . lsp-javascript)
```

Run `M-x my-install-language-grammars` once to install the pinned grammars for
all 25 file-editing Tree-sitter modes bundled with Emacs 30.2, plus Swift and
Typst.
PHPDoc and JSDoc are included because Emacs' PHP mode requires them. All parser
revisions use ABI 14, matching this Emacs build. Until the required grammars are
available, existing major-mode associations stay unchanged. Add grammar sources
and mode mappings in `config.el`; add LSP clients in `plugins/lsp.el` when the
language should start LSP automatically.

Current common-language coverage is good for Rust, C, C++, Java, Python, Go,
Swift, Typst, JavaScript, TypeScript, and TSX: these have Tree-sitter modes plus
automatic LSP, and most also have formatter integration through `format-all`.
Bash, JSON, CSS, HTML, YAML, TOML, Dockerfile, CMake, Lua, Ruby, PHP, Elixir,
HEEx, C#, and protobuf have syntax support through Tree-sitter or a dedicated
major mode, but they do not currently start an LSP server automatically. Add the
appropriate language server package and hook in `plugins/lsp.el` when one of
those languages needs completion, diagnostics, and project-aware navigation.

Typst support uses the `tinymist` language server and a compiled Tree-sitter
grammar. The custom translation package uses the `trans` executable from
translate-shell.

Swift support requires Xcode or a Swift toolchain containing `sourcekit-lsp`.
Optional format-on-save support uses SwiftFormat (`brew install swiftformat`).

Nerd Icons is declared in `packages.el`. Run `M-x nerd-icons-install-fonts`
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
