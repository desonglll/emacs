# Language setup

The current Mac has all tools for Go, Java, Rust, Zig, Lua, C/C++, JS/TS/TSX, Vue 3,
YAML, TOML, Markdown, and shell editing. Restart Emacs after setup, then run
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
brew install zig zls lua-language-server jdtls taplo shfmt shellcheck clang-format marksman
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
  2024. `rustfmt.toml` remains authoritative. The `rust-mode` Cargo commands
  remain available in `rust-ts-mode` for build, check, test, run, and Clippy.
  Rust buffers show inferred variable types as inlay hints; toggle them for the
  current buffer with `M-x lsp-inlay-hints-mode`.
  Local file aliases are resolved before visiting so LSP and Flycheck use the
  same canonical path.
  In Cargo compilation output, `RET` on a rustc location jumps to the source;
  `M-g e` searches all recognized compilation errors.
- **Zig:** `zig-mode` handles `.zig` source and `.zon` package manifests. ZLS
  supplies completion, navigation, diagnostics, rename, inlay hints, and code
  actions. `zig fmt` formats saves; manifests are passed its `--zon` flag.
- **Lua:** `.lua` files use `lua-ts-mode` when its grammar is installed, with
  `lua-mode` as the built-in fallback in Emacs 31. Both automatically connect to
  LuaLS (`lua-language-server`) for completion, navigation, diagnostics, rename,
  and code actions. The executable is installed through Homebrew; its client
  ships with `lsp-mode`. Use a project-root `.luarc.json` for runtime versions,
  library paths, and environment-specific globals rather than global defaults.
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
- **Markdown:** `.md`, `.markdown`, and `.mdown` use `markdown-mode`, with wiki
  links highlighted. Markdown and GFM buffers use Marksman for link completion,
  definition/reference navigation, heading symbols, and broken-link diagnostics.
  Keep related notes in one LSP project root: a Git repository or a folder with
  an empty `.marksman.toml` is suitable. Emacs recognizes that marker as a
  project root even without Git, including from nested note directories.
  When LSP asks for a root, select that folder. A single-file session cannot
  resolve links to the rest of a vault.
  Marksman is an external executable installed through Homebrew; its LSP client
  is already bundled in `lsp-mode`. Markdown formatting remains with Prettier.

Flycheck is the shared diagnostics display for LSP. `M-g f` uses
`consult-flycheck`; `C-c d b` opens the current buffer's error list and
`C-c d p` shows collected diagnostics from the current project. Both lists use
the bottom panel. Enabling Flycheck disables Flymake in that buffer. LSP files
wait for server initialization instead of running an additional standalone
checker first. Other supported local files enable Flycheck after local settings
load; large and remote files skip automatic checks. `M-x flycheck-verify-setup`
shows the active checker and executable availability.

Inline messages use Flycheck's built-in `flycheck-annotate-mode`: the current
line shows full diagnostics underneath, and other lines show a compact message
after the code. Error IDs are included when supplied by the checker. The text
is an overlay, so it does not change the file. `M-x flycheck-annotate-mode`
toggles inline messages in the current buffer. Gruber Darker uses the existing
muted severity colors for the messages.

Prettier uses the nearest project's executable when available, including its
plugins and configuration. `.prettierrc`, `.prettierignore`, `.editorconfig`,
`.clang-format`, and Taplo settings are not overridden by fixed indentation
flags. Java and Rust format on save only after their language server is ready.

`C-c t f` toggles save formatting for the current buffer across all languages,
including Java and Rust. Manual formatting still works when the switch is off.
To disable save formatting for a project, put this in its `.dir-locals.el`:

```elisp
((nil . ((my-format-on-save . nil))))
```

Reopen existing project buffers or run `M-x normal-mode` to reread local settings.
Explicitly disabling `format-all-mode` also stops the Java/Rust save hook.

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
| Cargo build / check | `C-c C-c C-u` / `C-c C-c C-k` |
| Cargo test / run / Clippy | `C-c C-c C-t` / `C-c C-c C-r` / `C-c C-c C-l` |
| Server commands | `C-c l` |
| Toggle automatic formatting | `C-c t f` |

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
and subsequent saves, actual C/Zig/TS/shell/TOML formatting, and workspace snapshot
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
[Vue server integration](https://github.com/vuejs/language-tools/discussions/5456),
[Marksman](https://github.com/artempyanykh/marksman),
[Flycheck](https://www.flycheck.org/en/latest/user/installation.html).

Markdown/Flycheck checks, including a real Marksman process in a temporary
two-document project, are in `tests/marksman-tests.el`. Use that test file with
the focused batch command above to verify link navigation, completion,
diagnostic delivery, and the buffer/project list controls.

Verified on 2026-10-28 with Emacs 30.2, Marksman 2026-02-08, and Flycheck
40.0-snapshot: ten focused checks passed. A real Marksman process resolved a
cross-file heading link, completed a wiki link, and delivered two deliberately
broken-link diagnostics through Flycheck. The checks also covered project
error lists, `.marksman.toml` roots without Git, existing language routing,
Markdown hard breaks, completion, and Gruber Darker theme reloads.
Three additional focused checks verified inline messages from real Marksman
diagnostics in both the current-line and end-of-line layouts, unchanged file
contents, the diagnostics panel, and theme reloads.

Verified on 2026-11-09 with Emacs 31.1 and LuaLS 3.19.2: batch initialization,
`lua-mode` fallback without a grammar, and `lua-ts-mode` LSP routing passed.
A real LuaLS process in a temporary project returned local-variable completion,
definition locations, document symbols, and diagnostics displayed by Flycheck.
Feature requests were checked after the server's asynchronous initial analysis.
