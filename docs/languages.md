# Language setup

The current Mac has all tools for Go, Java, Rust, C/C++, JS/TS/TSX, Vue 3,
YAML, TOML, and shell editing. Restart Emacs after setup, then run
`M-x my-language-tools-check` to see the resolved executable paths.

## Reproducible installation

Node tools are installed inside `var/language-tools`, with exact versions and
transitive dependencies recorded in `tools/language-tools/package-lock.json`.
They do not replace project packages or global npm installations.

```sh
# Node >= 22.22.2 is required by the pinned TypeScript language server.
./scripts/setup-language-tools

# If npm needs a proxy, pass it explicitly for this installation only:
./scripts/setup-language-tools --https-proxy=http://127.0.0.1:7897

# macOS tools; clangd comes with the Xcode Command Line Tools.
brew install jdtls taplo shfmt shellcheck clang-format
go install golang.org/x/tools/gopls@latest
rustup component add rust-analyzer rustfmt rust-src
```

Go, a Rust toolchain, and the project's Java runtime/build tools must also be
installed. The Homebrew JDTLS launcher supplies its own compatible Java
runtime; a project's required JDK is a separate setting. JDTLS reuses the
system installation and stores workspace data in `var/lsp-java/workspace/`.
Its package downloader is disabled for that installation.

On another OS, install the same executable names through its package manager.
`~/go/bin`, `~/.cargo/bin`, and the local Node tool directory are added to
Emacs's tool path when present. Envrc can supply a project's own environment.

## Project settings

- **Go:** open files inside the module containing `go.mod` or `go.work`.
  Gopls supplies completion, navigation, diagnostics, rename and code actions;
  gofmt handles saves. Use LSP code actions for missing imports.
- **Java:** open the Maven, Gradle, or Eclipse project root. JDTLS imports its
  build model and supplies completion, diagnostics, refactoring and formatting.
  Maven/Gradle wrapper dependencies still need to be resolvable by the project.
  Standalone Java files have less project information available.
- **Rust:** open a Cargo project. Rust-analyzer supplies semantic features and
  invokes rustfmt using the Cargo edition, including async syntax in edition
  2024. `rustfmt.toml` remains authoritative.
- **C/C++:** provide `compile_commands.json` for accurate includes and compiler
  flags. For CMake, configure with `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON`; clangd
  searches the project and conventional build directories. `.clangd` can
  specify a nonstandard compilation database. Formatting follows `.clang-format`.
- **JS/TS/TSX:** keep `tsconfig.json` or `jsconfig.json` and installed project
  dependencies. The project TypeScript SDK takes precedence when it provides
  tsserver. TypeScript 7 projects fall back to the bundled TypeScript 6 editing
  service, so TS7-specific language changes may need a future client update.
- **Vue:** Vue 3 single-file components use web-mode for template/script/style
  editing and both TypeScript and Vue servers for semantics. The Vue plugin
  and server versions are pinned together. Vue 2 needs a separately compatible
  toolchain and is not covered by this setup.
- **YAML/TOML:** schemas provide additional key completion and validation.
  Generic files still receive syntax diagnostics and formatting. Schema
  downloads depend on network access.
- **Shell:** a correct `#!/bin/bash` or `#!/bin/sh` shebang identifies the
  dialect. Bash LSP uses ShellCheck for diagnostics. Shfmt receives the real
  filename so `[*.sh]` rules in `.editorconfig` apply correctly.

Prettier uses the nearest project's executable when available, including its
plugins and configuration. `.prettierrc`, `.prettierignore`, `.editorconfig`,
`.clang-format`, and Taplo settings are not overridden by fixed indentation
flags. Java and Rust format on save only after their language server is ready.

## Daily commands

| Action | Binding |
| --- | --- |
| Complete at point | `M-TAB` / `C-M-i` |
| Definition / return | `M-.` / `M-,` |
| References | `M-?` |
| Rename symbol | `C-c l r r` |
| Code actions | `C-c l a a` |
| Buffer / project diagnostics | `C-c d b` / `C-c d p` |
| Format region or buffer | `C-M-\` |
| Server commands | `C-c l` |

Use `M-x lsp-workspace-restart` after changing a project's environment or SDK.
Buffers larger than 2 MiB skip automatic LSP and formatting, as before.

## Focused checks

Run these from the configuration directory; they use temporary projects:

```sh
emacs -Q --batch \
  --eval '(setq debug-on-error t use-package-expand-minimally t)' \
  -l early-init.el -l init.el \
  --eval "(progn (run-hooks 'after-init-hook 'emacs-startup-hook) (straight--transaction-finalize) (setq kill-emacs-hook nil))" \
  -l tests/language-tests.el -l tests/workspace-state-tests.el \
  -f ert-run-tests-batch-and-exit
```

The checks cover all requested file associations, formatter discovery, LSP
routing, Markdown hard breaks, EditorConfig, project-local Prettier on first
and subsequent saves, actual C/TS/shell/TOML formatting, and workspace snapshot
restoration and failure safety.

For explicit real-server smoke checks, add `-l tests/language-server-tests.el`
and replace the final `-f` invocation with:

```sh
--eval '(ert-run-tests-batch-and-exit "my-live-server")'
```

These start the installed servers, request document symbols, verify diagnostics
for deliberately invalid code, and exercise Java/Rust formatting. They do not
open or build user projects. They are separate from ordinary configuration
checks because they require the external toolchains.

Protocol references: [TypeScript language server](https://github.com/typescript-language-server/typescript-language-server),
[Vue server integration](https://github.com/vuejs/language-tools/discussions/5456).
