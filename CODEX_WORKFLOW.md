# CODEX_WORKFLOW.md

Last updated: 2026-09-23

# Codex Workflow for the Plasma Proteomics Project

This file defines how Codex should work on this long-term project.

The goal is to:

- preserve project continuity across interrupted sessions
- minimise unnecessary context usage
- avoid rescanning the whole repository
- keep scientific decisions separate from code-maintenance history
- maintain a reliable breakpoint for the next session

---

# 1. Files to read first

At the beginning of every new Codex session, do NOT recursively scan the repository.

First read:

```text
CODEX_WORKFLOW.md
PROJECT_CONTEXT.md
FILE_STATUS.md
TASK_CURRENT.md
```

Their roles are:

```text
CODEX_WORKFLOW.md  = working protocol
PROJECT_CONTEXT.md = scientific / analytical truth
FILE_STATUS.md     = file-role / activity truth
TASK_CURRENT.md    = current work-progress / breakpoint truth
```

Historical README files, old scripts, deprecated scripts, and archived files do not replace these roles.

---

# 2. Domain-specific authority model

Do NOT use one universal priority list for every kind of conflict.

Use the authoritative source appropriate to the question.

## Scientific / statistical design

Authoritative source:

```text
PROJECT_CONTEXT.md
```

Examples:

- primary model
- thresholds
- missing-value policy
- active analysis branches
- scientific interpretation of exposure groups
- primary contrasts
- sensitivity-analysis role

`TASK_CURRENT.md` must not silently override scientific design.

If the task requires changing scientific design, update `PROJECT_CONTEXT.md` explicitly.

---

## File role / activity status

Authoritative source:

```text
FILE_STATUS.md
```

Examples:

- ACTIVE
- FROZEN
- DEPRECATED
- HOLD
- REVIEW
- COMPATIBILITY
- canonical entry point role

Do not infer file status from filename numbering or directory location alone.

---

## Current work progress / breakpoint

Authoritative source:

```text
TASK_CURRENT.md
```

Examples:

- what has already been completed
- what is partially complete
- which file is currently in progress
- the next exact file to open
- what is held for later

---

## Implementation truth

Authoritative source:

```text
current active source code
```

Use source code to determine what is actually implemented.

If source code and `TASK_CURRENT.md` disagree about whether a code edit exists, inspect the relevant file and update the breakpoint.

Do NOT use an implementation discrepancy as permission to redesign scientific logic.

---

## Historical rationale / chronology

Authoritative source:

```text
README files
```

README files explain what changed in previous rounds.

They are not the live source for current scientific design, current file role, or current breakpoint.

---

# 3. Repository-reading rule

After reading the four control files:

1. Identify the current `In progress` item in `TASK_CURRENT.md`.
2. Read only the file required for that item.
3. Read direct dependencies only when necessary to understand:
   - an input
   - an output
   - a helper function
   - a shared plotting function
   - a file contract
4. Do not recursively inspect the entire repository.
5. Do not read all historical README files.
6. Do not reopen frozen mapping code unless the task explicitly concerns mapping.
7. Do not inspect deprecated scripts unless the task explicitly requires historical comparison.
8. Do not reread files marked DONE unless a concrete dependency or consistency issue requires it.

The purpose is to reduce context consumption and avoid reinterpreting already settled project decisions.

---

# 4. Work-start checklist

Before modifying code, confirm:

From `PROJECT_CONTEXT.md`:

- current scientific question
- current main analysis branches
- locked statistical design
- terminology
- missing-value rules

From `FILE_STATUS.md`:

- active files
- frozen files
- deprecated files
- held files

From `TASK_CURRENT.md`:

- completed work
- current in-progress file
- remaining to-do work
- exact next breakpoint

If actual source code and `TASK_CURRENT.md` differ, inspect only the relevant target file and correct the breakpoint.

Do NOT independently redesign the scientific workflow because of a code discrepancy.

---

# 5. Default execution policy

Unless `TASK_CURRENT.md` explicitly says otherwise:

```text
DO NOT RUN THE ANALYSIS.
```

Default maintenance tasks allow code and documentation changes only.

Do NOT:

- execute R analysis scripts
- execute Python analysis scripts
- run the complete pipeline
- refit statistical models
- rerun limma
- rerun detection models
- regenerate figures
- regenerate statistical result tables
- modify raw data
- change locked thresholds
- change the locked primary statistical model
- delete extra scripts
- archive extra scripts
- restore deprecated analyses

Static inspection is allowed when needed to understand or edit code.

Static syntax checking should only be used when explicitly requested or when it does not execute the scientific workflow.

---

# 6. Work incrementally

Do not try to solve the whole repository in one pass.

Work file-by-file or module-by-module.

Preferred pattern:

```text
read breakpoint
↓
open one target file
↓
make only the required change
↓
update TASK_CURRENT.md
↓
move to the next target
```

Avoid repeatedly reopening files already marked DONE unless:

- the current file directly depends on them
- a consistency problem appears
- the current task explicitly requires re-review

---

# 7. Update TASK_CURRENT.md continuously

`TASK_CURRENT.md` is the live breakpoint file.

Do not wait until the entire large task is finished before updating it.

After completing a meaningful file / subtask, update `TASK_CURRENT.md`.

Maintain:

```text
Completed / established
File-by-file breakpoint table
In progress
To do
Hold
```

When a file is completed:

1. change its table status to `DONE`
2. record the completed state briefly
3. identify the next real unfinished file
4. make that file the next `In progress` target

`TASK_CURRENT.md` should always answer:

> If this session stopped right now, what exact file should the next Codex session open?

---

# 8. What to record in TASK_CURRENT.md

The current breakpoint should clearly state:

- files actually modified
- files already completed
- partially completed files
- exact next file or module
- exact next action
- work still remaining
- work deliberately held
- important restrictions
- whether analysis was executed

Do not use vague status such as:

```text
continue plotting work
```

Prefer:

```text
DONE:
- detection_gradient.py
  - independent figures completed
  - output naming reviewed

IN PROGRESS:
- design_composition.py
  - next: finish run-date label cleanup

TODO:
- complete_four_layers.py
- 06b_limma_robustness.R
```

The more precise the breakpoint, the less context the next session needs.

---

# 9. Update FILE_STATUS.md only when file roles change

Do not mechanically update `FILE_STATUS.md` after every code edit.

Update it only when a file's project role changes.

Examples:

```text
ACTIVE -> FROZEN
ACTIVE -> DEPRECATED
REVIEW -> ACTIVE
HOLD -> ACTIVE
new canonical script added
script renamed
canonical entry-point role changed
new main module introduced
```

Pure plotting changes, formatting changes, comments, or small bug fixes usually do not require a file-status change.

---

# 10. Update PROJECT_CONTEXT.md only when scientific design changes

Do not repeatedly rewrite `PROJECT_CONTEXT.md` for routine code maintenance.

Update it only when the scientific or analytical architecture changes.

Examples:

- primary analysis branch changes
- new branch becomes part of the main workflow
- a branch is removed from the main workflow
- primary threshold changes
- formal sensitivity threshold changes
- primary statistical model changes
- missing-value policy changes
- main contrast changes
- scientific interpretation of group labels changes
- a sensitivity analysis becomes primary or vice versa

Routine plotting edits should not alter this file.

---

# 11. README policy

README files are chronological change records.

They are not the live project state.

After a meaningful maintenance or feature round, create a NEW README version in the existing:

```text
reademe/
```

folder.

Do not overwrite older README files.

A new README should record:

- files modified
- files added
- files renamed
- files deprecated
- major implementation changes
- plotting changes
- terminology changes
- dependencies added or removed
- whether statistical logic changed
- whether analysis was executed
- remaining unfinished work

Keep README files concise.

Do not duplicate the entire content of `PROJECT_CONTEXT.md`.

---

# 12. R coding rule

Before finalising modified R code, check:

```text
[[ ]]
[ ]
( )
{ }
```

Never split double-bracket indexing.

Correct:

```r
x[[name]] <- value
results[[contrast_name]]
folds_now[[fold_id]]
pathway_rank[[sample_name]]
```

Incorrect malformed indexing must never be introduced.

Also check ggplot continuation carefully.

Do not leave a standalone `+` as a separate expression.

---

# 13. Interrupted-session rule

Codex sessions may stop because of usage limits, context limits, or user interruption.

Because abrupt limits may occur, do not wait until the end of a long session to record progress.

After every meaningful completed file / subtask:

- update `TASK_CURRENT.md`
- mark the file DONE if truly complete
- record the exact next target

If the session can still modify files before stopping, update `TASK_CURRENT.md` immediately.

Record:

- what was completed
- what was partially completed
- the exact next step
- any file currently being edited
- any unresolved issue

The project should never depend on chat history alone for resumption.

---

# 14. New-session resume procedure

When resuming after interruption:

1. Read `CODEX_WORKFLOW.md`.
2. Read `PROJECT_CONTEXT.md`.
3. Read `FILE_STATUS.md`.
4. Read `TASK_CURRENT.md`.
5. Find the first unfinished item in the breakpoint table / `In progress`.
6. Open only that relevant target file.
7. Continue from the recorded next action.
8. Do not rescan files marked DONE.
9. Read direct dependencies only if needed.
10. Read the latest README only when historical clarification is necessary.

This should be the default resume path.

---

# 15. Usage-efficiency rule

Context efficiency is an explicit project requirement.

Avoid:

- repository-wide scans without need
- rereading completed files
- loading large output directories
- reading all README versions
- opening deprecated scripts
- reading entire large scripts when only one known section is needed
- repeatedly summarising settled project background

Prefer:

- exact file paths
- exact modules
- exact function names
- exact breakpoint descriptions
- direct dependency reading
- incremental edits
- continuous `TASK_CURRENT.md` updates

---

# 16. Completion rule for each work round

Before declaring a work round complete:

1. Ensure the requested code/document changes are complete.
2. Update `TASK_CURRENT.md`.
3. Update `FILE_STATUS.md` only if file roles changed.
4. Update `PROJECT_CONTEXT.md` only if scientific design changed.
5. Create a new README version if the round is substantial enough to deserve a historical record.
6. Clearly leave the next breakpoint if unfinished work remains.

---

# 17. Core principle

The project must remain resumable without relying on the previous chat transcript.

At any time, a new Codex session should be able to continue by reading:

```text
CODEX_WORKFLOW.md
PROJECT_CONTEXT.md
FILE_STATUS.md
TASK_CURRENT.md
```

and then opening only the specific file required by the current breakpoint.
