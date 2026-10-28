# Workflow controls

Restart Emacs to load these changes. Native Dired remains the directory browser.

## Workspaces and buffer cleanup

Startup begins with a fresh workspace. No workspace snapshot is restored at
startup or written on exit, including after manually saving or restoring one.
Existing snapshots remain available for explicit restoration.

`C-c w C-s` manually saves the current file buffers and layouts atomically to
`var/workspaces.el`, keeping the previous snapshot as `var/workspaces.el.bak`.
`C-c w C-l` explicitly restores a snapshot. After deleting a workspace, save
manually if the stored snapshot should also reflect that deletion. Use
`M-x persp-state-save` to choose another snapshot file. Snapshots do not include
unsaved text or running jobs. Reloading `modules/workspace-state.el` also removes
the old startup/exit hooks and automatic-saving advice in an existing session.

`M-x my/kill-other-buffers` closes other unmodified user buffers in the current
workspace. A buffer shared with another workspace is only removed from the
current one. Terminals, process buffers, and internal buffers are preserved.
With `C-u`, modified files use Emacs's normal save/discard prompt; modified
non-file buffers require confirmation. The prefix does not broaden the scope.

## Buffer list and directory search

`C-x C-b` and `C-c b` open native Ibuffer in the selected window. `C-u` makes
the list fill the frame. Unsaved files and terminals have their own groups;
other files are grouped by full project path, keeping same-name projects
distinct. Remote buffers are grouped without probing their hosts for projects.
Groups are rebuilt each time the command opens the list and on `g` refresh.

Ibuffer retains its normal controls: `RET` visits, `m` marks, `u` unmarks,
`S` saves marked buffers, `D` deletes marked buffers with its usual prompts,
`/ m` filters by major mode, `/ f` by filename, `/ /` clears filters, and
`g` refreshes the list. `q` returns to the previous buffer.

`M-x fd-cd` uses Consult's asynchronous fd search. The current directory is
available immediately; typing starts a search, with spaces supporting multiple
search terms. Results arrive without waiting for a complete directory scan.
`C-u M-x fd-cd` chooses a search root first. Spaces and Chinese directory names
are supported. `.git` stays excluded and normal fd ignore rules apply.
`C-g` cancels the search and its process without changing the buffer's directory.

## Save formatting and narrow windows

`C-c t f` controls automatic formatting in the current buffer, including the
Java/Rust LSP backend. Manual formatting remains available. For a persistent
project-wide opt-out, use `my-format-on-save` in `.dir-locals.el`, as shown in
[language setup](languages.md#project-settings).

Long Git branch labels are abbreviated with a 24-character budget. Treemacs
and Imenu List use about 18% of the frame width, capped at 32 columns and
respecting Emacs's minimum window size. They adapt when the frame width changes;
manual sidebar resizing is preserved until the next frame-width change.

The eight previously unlocked package repositories are now pinned in
`straight-versions.el`, using their installed revisions. Existing pins were
retained; this change does not upgrade packages.

## Focused checks

These checks use isolated Emacs processes, temporary projects, and test snapshots:

```sh
emacs -Q --batch \
  --eval '(setq debug-on-error t use-package-expand-minimally t)' \
  -l early-init.el -l init.el \
  --eval "(progn (run-hooks 'after-init-hook 'emacs-startup-hook) (straight--transaction-finalize) (setq kill-emacs-hook nil))" \
  -l tests/workspace-state-tests.el -l tests/format-policy-tests.el \
  -l tests/buffer-management-tests.el -l tests/directory-search-tests.el \
  -l tests/sidebar-layout-tests.el -f ert-run-tests-batch-and-exit
```

They cover manual snapshots and removal of automatic persistence, formatting
opt-outs and toggles, cross-workspace cleanup, process preservation, project grouping,
live asynchronous fd searches and cancellation, and sidebar sizing/focus.
Sidebar checks exercise real Emacs windows in batch mode; graphical appearance
still needs a check in the regular GUI session.

Verified on 2026-10-27 with Emacs 30.2: the seven workspace/workflow checks
passed, including manual snapshot round trips, failed-save protection, and
removal of the old persistence hooks/advice on reload. Fresh startup hooks
also ran with workspace loading/saving blocked, without attempting either.
