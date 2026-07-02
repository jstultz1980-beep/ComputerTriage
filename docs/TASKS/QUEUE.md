# Task Queue

This file is the task-state source of truth alongside `docs/HANDOFF.md`.

## Current Rule
Exactly one task may have `Active` status at a time. No implementation work may begin unless the active task exists under `docs/TASKS` and `docs/HANDOFF.md` names the same task.

## Active

| Task | Owner | Status | Purpose |
|---|---|---|---|
| `TASK-0041-UI-Counter-Audit` | ChatGPT | Active | Required audit gate because the UI counter reached 10 / 10 after TASK-0029. |

## Queued

| Task | Owner | Status | Purpose |
|---|---|---|---|
| `TASK-0021-HEPHAESTUS-Rule-Catalog-Expansion` | Codex | Queued | Expand deterministic rules after the v1 vertical slice exists and validates. |
| `TASK-0022-HEPHAESTUS-Portable-Tool-Classification` | ChatGPT | Queued | Classify optional portable tools, including whether LatencyMon should be tracked, ignored, or handled separately. |
| `TASK-0030-Print-Tab-Data-Path-Cleanup` | Codex | Queued | Remove the print data-folder path display and reclaim the space. |
| `TASK-0031-Triage-Page-Simplification` | Codex | Queued | Reduce Triage primary actions to Quick Triage and Full Triage and revisit live log visibility. |
| `TASK-0032-Computer-Tab-Summary-Redesign` | Codex | Queued | Replace the computer profile list with a richer current-computer summary and LED status indicators. |
| `TASK-0033-Directory-Tab-Direction-And-Embedding-Plan` | ChatGPT | Queued | Decide whether Directory remains a launcher or becomes a domain insight page. |
| `TASK-0034-Embedded-Tool-Experience-Roadmap` | ChatGPT | Queued | Prioritize launch-only tools that should become embedded tab experiences. |
| `TASK-0036-Page-Health-Indicators` | Codex | Queued | Add compact Windows Update service and Wi-Fi signal-strength indicators. |
| `TASK-0037-Activity-Page-Running-Tool-Tracking` | Codex | Queued | Refine Activity page running-tool tracking, including network tools and compact controls. |
| `TASK-0038-Modern-Control-Style-System` | Codex | Queued | Replace default-looking utility buttons with a consistent modern control style. |
| `TASK-0039-Software-Tab-Launchable-And-Installable-Inventory` | ChatGPT | Queued | Classify Software tab apps/installers and research Registrar Registry Manager portability. |
| `TASK-0040-Software-Tab-Launchable-And-Installable-Implementation` | Codex | Queued | Implement accepted Software tab separation between launchable apps and installable stored programs. |

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
| `TASK-0020-ARGUS-Input-Contract-ADR` | Completed | ADR-0003 accepted; ARGUS input contract, trust model, and focused TASK-0023 implementation scope finalized. |
| `TASK-0023-ARGUS-Foundation-Implementation` | Completed | Minimal ARGUS foundation slice implemented and validated against HEPHAESTUS Local Analysis artifacts. |
| `TASK-0024-Quick-Dx-Layout-Adjustment` | Completed | Adjusted Quick Diagnosis tab layout so Quick Target Checks owns the full left column and Quick Diagnosis controls are compacted into the right column. |
| `TASK-0025-Quick-Dx-Last-Scan-Label-Fix` | Completed | Fixed the clipped Last Quick Diagnosis label in the compact right-column Quick Diagnosis block. |
| `TASK-0026-Quick-Dx-Fixed-Internet-Targets` | Completed | Replaced the editable Quick Diagnosis internet target with a fixed primary/backup target chain. |
| `TASK-0027-GUI-Polish-QuickDx-Header-Choco-Theme` | Completed | Polished Quick Dx spacing, header health badge space, Choco layout, surface gradient/texture, and added Terminal Dark. |
| `TASK-0035-Documentation-Task-System-Audit` | Completed | Audited documentation/task-state consistency, reset audited counters, and cleared the implementation gate. |
| `TASK-0028-Quick-Dx-Compact-Run-Panel` | Completed | Removed the visible Quick Dx internet target chain and compacted the run panel while preserving internal fallback targets. |
| `TASK-0029-Choco-Page-Layout-Refinement` | Completed | Reworked the Choco status area into a compact strip with readable action buttons and preserved existing package-management behavior. |

## Reconciliation Decision

`TASK-0010-Foundation-Audit` must not remain active because `TASK-0010` is already occupied by `TASK-0010-Classify-Drift-And-Status-Report`, and the repository contains `TASK-0011-Foundation-Audit` as the completed Foundation Audit task. The current reconciliation does not delete or rename historical task files. The clean source of truth is:

- Historical TASK-0010 remains completed as drift classification/status reporting.
- The invalid duplicate TASK-0010 Foundation Audit prep task is archived.
- Foundation Audit remains completed as TASK-0011.
- Current active task is TASK-0041. Further implementation is paused until the UI counter audit completes.
