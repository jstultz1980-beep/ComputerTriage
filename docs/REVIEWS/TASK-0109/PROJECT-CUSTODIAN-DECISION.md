# TASK-0109 Project Custodian Decision

## Decision

The TASK-0108 Task System Audit Preparation evidence is accepted.

Only the Task System counter is reset from `25 / 25` to `0 / 25`.

A focused cleanup task must precede TASK-0098 because the accepted audit contains unresolved High and Medium task-state consistency defects that can mislead automation or reintroduce superseded work.

## Debt Dispositions

### TS-AUD-01 — Duplicate TASK-0010 identifier

Accepted. Preserve both historical files. `TASK-0010-Classify-Drift-And-Status-Report.md` remains the canonical TASK-0010 record. `TASK-0010-Foundation-Audit.md` remains an archived legacy duplicate and must carry an explicit legacy alias that points to TASK-0011 and REVIEW-0001. Do not rename or delete historical files.

### TS-AUD-02 — Superseded tasks still marked Queued

Accepted as High. TASK-0077, TASK-0078, and TASK-0079 must be changed to `Superseded` and must explicitly identify TASK-0100, TASK-0093, and TASK-0092 respectively as their replacements.

### TS-AUD-03 — Terminal status vocabulary

Accepted. `Complete` is the canonical terminal status for active and nonarchived task records. `Archived` and `Superseded` remain distinct terminal states. Historical archived material does not require bulk rewriting. Normalize current and nonarchived task records only.

### TS-AUD-04 — Stale Error Handoff detail

Accepted. `docs/ERROR-HANDOFF.md` must become a compact explicit `Clear` record with no stale active-task text. Resolved incident detail must remain in history or be linked from the Clear record.

### TS-AUD-05 — Punch-list item 61

Accepted for focused reconciliation. Compare the original punch request against TASK-0095 evidence. Close item 61 only if the plugin discovery, registration, compatibility, lifecycle, isolation, and failure requirements are fully satisfied. Otherwise record one narrow remaining gap; do not create a broad feature task.

### TS-AUD-06 — Commit fan-out

Accepted as process guidance. Prefer one atomic Custodian decision commit and one closeout commit when practical. Existing history will not be rewritten.

## Sequencing

1. Activate TASK-0110 Task System Consistency Cleanup.
2. After TASK-0110 passes validation, activate TASK-0098.
3. Preserve the remaining order: TASK-0098, TASK-0099, TASK-0100, TASK-0080.

## Constraints

- Preserve documented working-tree drift.
- Do not modify application code.
- Do not expand governance or architecture.
- Do not create feature work.
- Do not normalize archived historical records beyond the explicit duplicate alias and required stale-state corrections.
