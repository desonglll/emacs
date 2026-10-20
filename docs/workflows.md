# Workflow controls

Restart Emacs to load these changes. Native Dired remains the directory browser.

## Workspaces and buffer cleanup

Normal interactive startup restores `var/workspaces.el`; exit saves atomically
and keeps the previous snapshot as `var/workspaces.el.bak`. If Emacs starts by
opening a file while a snapshot already exists, that temporary session skips
both restoration and autosaving, so it cannot replace the saved workspaces.
A first session without an existing snapshot can still create one on exit.
An unreadable or broken snapshot disables automatic saving for that session.

`C-c w C-l` explicitly restores a snapshot. Restoring the default snapshot
resumes automatic saving, even in a temporary file session. `C-c w C-s` can
explicitly save the current layout instead; saving to the default snapshot
also opts the session into autosaving. Saving/loading another file does not.
Batch processes and daemon startup remain excluded from automatic persistence.
Snapshots include file buffers and layouts, not unsaved text or running jobs.

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

They cover snapshot protection and explicit restoration, formatting opt-outs
and toggles, cross-workspace cleanup, process preservation, project grouping,
live asynchronous fd searches and cancellation, and sidebar sizing/focus.
Sidebar checks exercise real Emacs windows in batch mode; graphical appearance
still needs a check in the regular GUI session.
