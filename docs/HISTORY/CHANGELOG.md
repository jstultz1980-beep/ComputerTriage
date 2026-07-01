# Changelog

## 2026-07-01
- Completed TASK-0017 triage manual run validation.
- Confirmed smoke and button-smoke validation pass from the current repository state.
- Documented runtime drift: `custom-tools.json` provenance migration was reset, and untracked `App/NetworkToolkit/LatencyMon/` was left untouched.
- Activated TASK-0018 HEPHAESTUS Local Analysis Engine v1 Design for ChatGPT.
- Reconciled TASK-0010 governance drift and completed `REVIEW-0001-Foundation-Audit`.
- Archived the invalid duplicate `TASK-0010-Foundation-Audit` active-state reference.
- Activated `TASK-0017-Triage-Manual-Run-Validation` as the only active task.
- Updated the roadmap sequence to validate first, then design HEPHAESTUS Local Analysis Engine v1 before implementation.
- Added the executive project status report and reset audited governance/task/documentation/roadmap counters.
- Prepared the repository for ChatGPT to execute TASK-0010 Foundation Audit.
- Added `docs/TASKS/QUEUE.md` with the official task lifecycle and one-active-task rule.
- Created and activated `docs/TASKS/TASK-0010-Foundation-Audit.md`.
- Added the Prime Directive and governance responsibilities to `docs/PROJECT-CHARTER.md`.
- Updated `PROJECT.md` and `docs/HANDOFF.md` to reference the task queue and active ChatGPT-owned audit.
- Recorded governance, documentation, task system, and roadmap/backlog counter increments.

## 2026-06-30
- Completed TASK-0016 tool source-of-truth correction.
- Centralized visible GUI tab tools and header search entries through `Get-GUIToolRegistry`.
- Added duplicate registry/search detection to button smoke validation.
- Hardened triage completion and cancellation so one triage run cannot repeatedly show completion or result-read dialogs.
- Completed TASK-0015 header search tab mapping correction.
- Rebuilt GUI header search results from the same tool placement path used by the visible tabs.
- Corrected `PsExec Helper` search placement to the dedicated `PsExec` tab.
- Completed TASK-0014 DHCP Sleuth restoration.
- Restored DHCP Sleuth as a tracked standalone toolkit app on the Infrastructure tab.
- Kept DHCP Sleuth runtime settings ignored and fixed smoke-test validation while another toolkit window is open.
- Completed TASK-0013 header tool search.
- Added GUI header autocomplete search that jumps to the proper tool tab.
- Completed TASK-0012 phase-transition readiness.
- Marked Phase 00 Foundation Zero complete and Phase 01 HEPHAESTUS Collection Baseline active.
- Updated handoff direction for the next implementation task.
- Completed TASK-0011 foundation audit.
- Broadened generated third-party tool configuration ignores.
- Reset runtime-only custom tool manifest drift.
- Normalized task status wording and corrected stale architecture root path casing.
- Added audit state tracking rule.
- Added subsystem change counters to `docs/HANDOFF.md`.
- Added `docs/HISTORY/CHANGE-LEDGER.md`.
- Established the rule that any subsystem reaching `10 / 10` changes requires an audit before further implementation work.

## 2026-06-29
- Established Foundation Zero project control structure.
- Added repository source-of-truth rule.
- Added handoff protocol.
- Added initial ADRs.
- Added task, ADR, and review templates.
