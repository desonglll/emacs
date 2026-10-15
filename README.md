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
- `modules/buffer-performance.el`: shared size limit for automatic editing extras.
- `modules/frame-title.el`: concise window titles with cached project labels.
- `plugins/terminal.el`: project-scoped Eat sessions and bottom-panel behavior.
- `plugins/dired.el`: asynchronous Git status for Dired and Dirvish.
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

## Completion

Vertico displays minibuffer candidates and Orderless matches space-separated
search terms. Prescient learns recent and frequent selections to sort Vertico
and Company candidates. Selectrum and selectrum-prescient are not used.

Restart Emacs after changing the configuration. Use `M-x` as usual, and use
`M-TAB` or `M-x company-complete` to trigger in-buffer completion manually.
Company also offers automatic completion after two characters. Use
`M-x prescient-forget` to forget an individual candidate.

Prescient saves its history to `prescient-save.el` under `my-state-directory`.
Orderless remains responsible for matching, Company does not apply an extra
length-based sort, and `my-recentf` retains its most-recently-used ordering.

## Appearance

`plugins/appearance.el` keeps the Gruber Darker theme and shared interface
colors in `my-ui-palette`. Fonts remain Iosevka Term SS15 at 16 pt with Sarasa
Term SC for Chinese. Frames have 10 px of inner padding, 8 px fringes, and
subtle 1 px window dividers. Source and text buffers get 0.1 line spacing;
terminal grids retain their normal spacing.

Company and Vertico share a muted selection color. Nerd Icons adds monochrome
file and buffer icons to completion alongside Marginalia annotations. The
Doom Modeline emphasizes the file, cursor position, Git branch, and Flymake
diagnostic count, while retaining input method and process indicators.
Branch names have no fixed character limit; narrow windows still use Doom
Modeline's compact layout.
Project and branch labels use muted blue-gray, with amber for unsaved/warning
indicators and muted red for conflicts/errors. The selected window has a
lighter charcoal modeline and an accent bar; other windows use a darker
background and softer, regular-weight text. Filename backgrounds blend into
the surrounding modeline.

Treemacs, Dirvish, Dired, and Imenu List share muted directory colors and a
consistent selection background. Treemacs and Imenu List use 32-column
sidebars; Treemacs follows the current file after a short idle delay. Search
highlights distinguish the active match in amber from other matches in a
subtle background. Selection, matching parentheses, and Flymake diagnostics
use the same palette. ANSI and Eat's standard 16 terminal colors are also
coordinated; programs that emit explicit RGB colors retain their own colors.

Window titles show a filename or a short sidebar label followed by the project
name, such as `init.el · emacs` or `Terminal · emacs`. Project labels are cached
when entering a buffer, so redisplay does not run project detection.

Indent Bars adds faint guides in programming buffers with a stronger current
indent level. macOS uses character bars for compatibility with Emacs 30's NS
build (see the [upstream compatibility notes](https://github.com/jdtsmith/indent-bars#compatibility));
other graphical builds use thin stipple bars. Pulsar briefly highlights
the destination after navigation, including Consult, Imenu, and Xref jumps.
Org Modern styles headings, lists, checkboxes, TODO labels, tables, and agenda
entries, using the Org version bundled with Emacs.

Restart Emacs to activate the complete setup. If icons appear as boxes, run
`M-x nerd-icons-install-fonts` once and restart. To disable an effect temporarily,
use `M-x indent-bars-mode`, `M-x pulsar-global-mode`, or `M-x org-modern-mode`.

Treemacs (`s-e`) initializes an empty workspace from the current project, or
the current directory outside a project. This also recovers a blank sidebar
left by cancelling the initial directory prompt. Existing workspace projects
and the normal show/hide toggle are preserved; `C-u s-e` selects a workspace.
In an already-running session, `M-x treemacs-add-and-display-current-project`
can populate the empty sidebar immediately.

Verified on 2026-10-15 with Emacs 30.2: batch startup, terminal modeline
rendering, completion icon generation, selection colors after theme reload,
code/Org hooks, unchanged Org text, terminal spacing isolation, and full branch
labels with active/inactive modeline styling after switching between split
windows. The latest colors have not yet been checked in a graphical screenshot.

## Startup and file performance

Straight checks package changes on saves instead of scanning every checkout
at startup. After editing a package outside Emacs, run `M-x straight-check-all`
to detect and rebuild modified packages. This tradeoff follows
[Straight's startup guidance](https://github.com/radian-software/straight.el#my-init-time-got-slower).
Yasnippet registers its bundled collection before initialization, avoiding a
second directory scan while retaining just-in-time snippet loading.

Format-All loads and checks formatter executables on the first save, including
formatting that save. Later saves use its normal hook. Manually disabling
`format-all-mode` also cancels pending automatic setup. The first save may
therefore take longer than later saves.

Buffers larger than 2 MiB skip automatic LSP, format-on-save, indentation
guides, Org Modern, line numbers, TODO highlighting, Git gutter updates, and
automatic Company popups. Syntax highlighting and manual completion remain
available. The size check runs before major-mode hooks; adjust
`my-large-buffer-threshold` in `local.el` to change the limit for newly opened
buffers. Individual tools such as `lsp`, `format-all-mode`, and
`indent-bars-mode` can still be started manually.

Company waits 0.15 seconds of idle time; its toggle uses the same setting.
Diff-Hl waits 0.8 seconds before refreshing while typing, and GPTel
autocomplete debug logging is disabled. Runtime GC remains at 16 MiB.

On this Mac with Emacs 30.2, three fresh batch processes with warm package
caches measured a median 1.11 seconds for configuration plus startup hooks,
0.35 seconds to open the first small Emacs Lisp file, and 0.064 seconds to
open a subsequent 2.4 MiB Emacs Lisp file. These are configuration/file-open
measurements, not GUI launch times, and exclude language-server startup.

Focused regression checks cover large-buffer exclusions, normal-buffer
behavior, snippet availability, completion toggling, and formatting on the
first and later saves:

```sh
emacs -Q --batch \
  --eval '(setq debug-on-error t use-package-expand-minimally t)' \
  -l early-init.el -l init.el \
  --eval "(progn (run-hooks 'after-init-hook 'emacs-startup-hook) (straight--transaction-finalize) (setq kill-emacs-hook nil))" \
  -l tests/buffer-performance-tests.el -f ert-run-tests-batch-and-exit
```

## Editing and help

Dired and Dirvish show Git changes in the left gutter: green for added or
untracked files, blue-gray for modified files, and red on directories containing
deleted files. Directories aggregate changes in their descendants; mixed
changes use blue-gray. Ignored and unchanged files have no marker. The colors
come from the same palette as the in-file Diff-Hl gutter. Dirvish reserves an
8 px left fringe so the markers fit.

Status refreshes asynchronously after saving a file, returning to a directory
window, or pressing `g` to refresh the listing. External changes are picked up
when returning or refreshing; there is no polling timer or per-file Git log
lookup. Remote directories skip these scans. Focused checks are in
`tests/dired-tests.el` and include nested folders, staged/untracked/ignored
files, save/commit refreshes, and Dirvish rendering.

Emacs 30's built-in Which-Key shows available keys after a prefix such as
`C-c p` or `C-c l`. Winner restores window layouts with `C-c <left>` and
`C-c <right>`; Repeat mode lets supported commands repeat with a single key.

Use `C-=` to expand a selection with Expreg, and `C-M-=` to contract it.
Expreg uses Tree-sitter when available. `C-x u` opens Vundo's visual undo
history: use `f`/`b` to move forward/backward, `n`/`p` to switch branches,
`RET` to keep the selected state, or `q` to return to the original state.

Helpful handles `C-h f`, `C-h v`, `C-h k`, and `C-h x` for functions,
variables, keys, and commands. The official `yasnippet-snippets` collection
loads with Yasnippet; use `M-x yas-insert-snippet` to choose a template or
`M-x yas-describe-tables` to see snippets for the current mode.

To edit search results across files, start `C-c f g` (Consult ripgrep),
then press `C-. E` to export the results through Embark. In the exported
buffer, press `C-c C-p` to edit, then `C-c C-e` to apply changes to the file
buffers. Review and save them with `C-x s`; `C-c C-k` cancels Wgrep editing.
Wgrep does not save files automatically. For semantic symbol renaming,
use `M-x lsp-rename` instead.

Use `C-c e` to start Iedit on the symbol at point, or select text first to
match that text. To limit editing to a block, start Iedit, select the block,
then press `C-c e` again. Changes to one occurrence are mirrored to the
others; press `C-c e` with no active region to finish. `C-;` remains bound
to Embark. TODO and FIXME comments are highlighted in programming and text
buffers (Org keeps its own TODO highlighting): `C-c t n` / `C-c t p` jump
forward / backward, and `C-c t o` lists the current buffer's markers.

## Terminal, HTTP requests, and project environments

`C-c t t` toggles an Eat panel along the bottom, using about 30% of the frame
height. The panel reuses the most recent terminal for the current project,
starting in its root directory; outside a project it uses the current
directory. Sessions are identified by the full root path, so projects with
the same name remain separate. Hiding the panel preserves the shell and any
running jobs and returns focus to the editor. Switching projects can replace
the visible panel while keeping the previous project's session running.

Use `C-u C-c t t` to create another session for the current project.
`M-x eat` retains Eat's ordinary full-window command. `C-c C-e` switches
to Emacs navigation and selection; `C-c C-j` resumes terminal input.
The panel toggle works in both of these modes. In raw char mode, use
`M-RET` to return to semi-char mode first. Terminal buffers have no line
numbers, extra line spacing, current-line overlay, or automatic Company popup.

Select output with the mouse, then use `M-w` or `s-c` (Command-C) to copy.
These bindings work in semi-char mode as well as Emacs mode; copied Chinese
text is stripped of Eat's invisible grid padding. For keyboard selection,
enter Emacs mode with `C-c C-e`, select and copy, then use `C-c C-j` to resume
terminal input. `C-y` or Command-V pastes in semi-char mode; `C-c C-c` sends
the terminal interrupt. `C-l` goes to the shell for normal clear/redraw.

On macOS, the first Eat load compiles `eat.ti` with `/usr/bin/tic` into
`var/eat-terminfo/` and supplies that directory through `TERMINFO` to new
shells. The bundled 32-bit entries are incompatible with Apple's older
ncurses: they caused `eat-truecolor: unknown terminal type`, broken clear/
redraw, and extra `?` characters around the zsh prompt's `➜` / `✗` symbols.
The native entries preserve Eat's terminal capabilities and fix the prompt
without changing fonts. They are rebuilt only if missing or older than the
source; package files remain untouched. Restart Emacs and start a new Eat
session to apply this to the shell environment.

The package recipe includes its terminfo and shell integration files. For
directory tracking, command status markers, and prompt navigation, add this
guarded snippet to the end of `~/.zshrc` (already installed on this Mac):

```sh
if [[ -n "${EAT_SHELL_INTEGRATION_DIR:-}" && -r "$EAT_SHELL_INTEGRATION_DIR/zsh" ]]; then
  source "$EAT_SHELL_INTEGRATION_DIR/zsh"
fi
```

It is active only inside Eat; start a new terminal session after adding it.
`C-c C-p` and `C-c C-n` move between shell prompts. After `cd`, file-opening
commands in the terminal buffer use the shell's updated directory. The
terminal's project identity stays unchanged, so it can still be found by
the panel shortcut. The prior local zsh configuration was backed up under
`var/backups/zshrc-before-eat-*` before appending the integration block.

Verified on 2026-10-15 with isolated Emacs 30.2 processes: panel sizing and
focus restoration, live-process reuse after hiding, same-name project
isolation, extra sessions, directory tracking, and command exit status.
The follow-up checks also cover Unicode copying without sending shell input,
all four native terminfo entries, the cache, `/usr/bin/clear`, and actual
`C-l` input with `TERM=eat-truecolor`. A separate real-zsh comparison reproduced
the `?➜` / `?✗` prompt with the bundled entries and clean symbols with native
entries.
An additional check started the actual configured zsh and confirmed automatic
shell integration with Treemacs and the terminal panel visible together.
Run the focused checks with the startup command above, replacing its test
file with `tests/terminal-tests.el`. Graphical appearance still needs visual
confirmation in the normal Emacs window.

Verb uses Org files for HTTP requests. For example, save this in an `.org`
file and put point in the request before pressing `C-c C-r C-r`:

```org
* Local health check :verb:
GET http://localhost:8080/health
Accept: application/json
```

`C-c C-r C-r` sends the request and displays its response; `C-c C-r C-e`
exports the request, including to curl. These bindings are local to Org mode.

Envrc loads per-project environments using the external `direnv` executable.
Install it with `brew install direnv` on macOS or `sudo pacman -S direnv`
on Arch Linux. In a project, create an `.envrc`, for example:

```sh
export APP_ENV=development
PATH_add bin
```

Review the file, then use `C-c E a` (`envrc-allow`) from a project buffer
to authorize it. Repeat this after changing `.envrc`. Use `C-c E r` to
reload the environment, or `C-c E d` to revoke authorization. Environments
are buffer-local; Envrc starts late during initialization so newly launched
project tools can use the appropriate environment. Restart an existing LSP
workspace after changing its toolchain or environment.

## Language support

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

- `C-x g`: Magit status.
- `M-<f2>`: Dirvish.
- `C-:` or `s-\`: Avy jump.
- `C-c f f`: find files with Consult and fd.
- `C-c f g`: search text with Consult and ripgrep.
- `C-c p`: Projectile commands.
- `C-c w`: Perspective workspace commands.
- `C-c c f` / `C-c c k`: Cape file / keyword completion.
- `C-c t w`: toggle whitespace display.
- `C-c <left>` / `C-c <right>`: restore / redo window layouts.
- `C-=` / `C-M-=`: expand / contract the selection.
- `C-x u`: visual undo history.
- `C-c e`: toggle simultaneous editing with Iedit.
- `C-c t t`: show / hide the current project's terminal panel.
- `C-u C-c t t`: create another project terminal session.
- `C-c t n` / `C-c t p` / `C-c t o`: next / previous / list TODO markers.
- `C-c E a` / `C-c E r` / `C-c E d`: allow / reload / deny a project environment.
- `C-c C-r C-r`: send the HTTP request at point in an Org buffer.
- `C-h f` / `C-h v` / `C-h k` / `C-h x`: enhanced help.
- `s-i`: Imenu List.
- `s-e`: Treemacs.
- `M-o`: Ace Window.

On macOS, Command is Super and Option is Meta.
