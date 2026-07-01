# Task Queue

This file is the task-state source of truth alongside `docs/HANDOFF.md`.

## Current Rule
Exactly one task may have `Active` status at a time. No implementation work may begin unless the active task exists under `docs/TASKS` and `docs/HANDOFF.md` names the same task.

## Active

| Task | Owner | Status | Purpose |
|---|---|---|---|
| `TASK-0020-ARGUS-Input-Contract-ADR` | ChatGPT | Active | Finalize the ARGUS input contract and evidence trust model before ARGUS implementation begins. |

## Queued

| Task | Owner | Status | Purpose |
|---|---|---|---|
| `TASK-0021-HEPHAESTUS-Rule-Catalog-Expansion` | Codex | Queued | Expand deterministic rules after the v1 vertical slice exists and validates. |
| `TASK-0022-HEPHAESTUS-Portable-Tool-Classification` | ChatGPT | Queued | Classify optional portable tools, including whether LatencyMon should be tracked, ignored, or handled separately. |
| `TASK-0023-ARGUS-Foundation-Implementation` | Codex | Queued | Implement only after TASK-0020 finalizes the ARGUS input contract and activates a specific implementation scope. |

## Completed / Historical

| Task | Status | Notes |
|---|---|---|
| `TASK-0010-Classify-Drift-And-Status-Report` | Completed | Historical TASK-0010. This number is already used and must not be reused for Foundation Audit. |
| `TASK-0010-Foundation-Audit` | Archived | Local governance-prep task created from an invalid duplicate TASK-0010 reference; superseded by completed TASK-0011 and REVIEW-0001. |
| `TASK-0011-Foundation-Audit` | Completed | Actual tracked Foundation Audit task. It supersedes the untracked/incorrect `TASK-0010-Foundation-Audit` reference. |
| `TASK-0012-Phase-Transition-Readiness` | Completed | Transitioned from Foundation Zero to Phase 01. |
| `TASK-0013-Header-Tool-Search` | Completed | GUI header tool search. |
| `TASK-0014-DHCP-Sleuth-Restoration` | Completed | DHCP Sleuth restoration per handoff history. |
| `TASK-0015-Header-Search-Tab-Mapping-Correction` | Completed | Search tab mapping correction per handoff history. |
| `TASK-0016-Tool-Source-Of-Truth-Correction` | Completed | GUI tool registry/source-of-truth correction per handoff history. |
| `TASK-0017-Triage-Manual-Run-Validation` | Completed | Existing smoke and button-smoke validation passed; runtime drift was documented and excluded. |
| `TASK-0018-HEPHAESTUS-Local-Analysis-Engine-v1-Design` | Completed | Design, ADRs, and focused TASK-0019 implementation scope completed. |
| `TASK-0019-HEPHAESTUS-Local-Analysis-Engine-v1-Implementation` | Completed | Minimal vertical slice implemented and validated locally; required artifacts generated and smoke tests passed. |
| `TASK-0024-Quick-Dx-Layout-Adjustment` | Completed | Adjusted Quick Diagnosis tab layout so Quick Target Checks owns the full left column and Quick Diagnosis controls are compacted into the right column. |
| `TASK-0025-Quick-Dx-Last-Scan-Label-Fix` | Completed | Fixed the clipped Last Quick Diagnosis label in the compact right-column Quick Diagnosis block. |
| `TASK-0026-Quick-Dx-Fixed-Internet-Targets` | Completed | Replaced the editable Quick Diagnosis internet target with a fixed primary/backup target chain. |
| `TASK-0027-GUI-Polish-QuickDx-Header-Choco-Theme` | Completed | Polished Quick Dx spacing, header health badge space, Choco layout, surface gradient/texture, and added Terminal Dark. |

## Reconciliation Decision

`TASK-0010-Foundation-Audit` must not remain active because `TASK-0010` is already occupied by `TASK-0010-Classify-Drift-And-Status-Report`, and the repository contains `TASK-0011-Foundation-Audit` as the completed Foundation Audit task. The current reconciliation does not delete or rename historical task files. The clean source of truth is:

- Historical TASK-0010 remains completed as drift classification/status reporting.
- The invalid duplicate TASK-0010 Foundation Audit prep task is archived.
- Foundation Audit remains completed as TASK-0011.
- Current active design gate is TASK-0020.
