# Change Ledger

This ledger records accepted engineering changes that increment subsystem audit counters.

A subsystem counter reaching `10 / 10` requires a new audit before additional implementation work continues.

After an audit is completed, the audited subsystem counter resets to `0 / 10` and the audit completion is recorded here.

| Change ID | Date | Task | Subsystem | Counter Change | Description |
|---|---|---|---|---:|---|
| CHG-0001 | 2026-06-30 | TASK-0009 | Repository Governance | +1 | Added audit state tracking rule to `PROJECT.md`, `docs/HANDOFF.md`, and this ledger. |
| CHG-0002 | 2026-06-30 | TASK-0009 | Task System | +1 | Added subsystem change counter process and next-task enforcement to the handoff workflow. |
| CHG-0003 | 2026-06-30 | TASK-0009 | Documentation | +1 | Documented audit counter reset behavior and mandatory audit trigger threshold. |
| CHG-0004 | 2026-06-30 | TASK-0010 | Repository Governance | +1 | Classified runtime drift, reset runtime-only custom tools manifest changes, and ignored generated ServiWin configuration. |
| CHG-0005 | 2026-06-30 | TASK-0010 | Documentation | +1 | Updated task and handoff records with runtime drift cleanup status and project status reporting. |
| CHG-0006 | 2026-06-30 | TASK-0011 | Repository Governance | reset to 0 / 10 | Completed foundation audit, verified GitHub tracking, reset runtime-only manifest drift, and broadened generated tool config ignore coverage. |
| CHG-0007 | 2026-06-30 | TASK-0011 | Documentation | reset to 0 / 10 | Completed foundation audit, corrected stale architecture path casing, and refreshed handoff state. |
| CHG-0008 | 2026-06-30 | TASK-0011 | Task System | reset to 0 / 10 | Completed foundation audit and normalized the TASK-0009 status wording. |
| CHG-0009 | 2026-06-30 | TASK-0012 | Task System | +1 | Created and completed phase-transition readiness task after the foundation audit. |
| CHG-0010 | 2026-06-30 | TASK-0012 | Roadmap/Backlog | +1 | Marked Phase 00 complete and Phase 01 HEPHAESTUS Collection Baseline active. |
| CHG-0011 | 2026-06-30 | TASK-0012 | Documentation | +1 | Refreshed handoff and changelog for post-foundation transition state. |
| CHG-0012 | 2026-06-30 | TASK-0013 | UI | +1 | Added header autocomplete tool search that navigates to the selected tool's tab. |
| CHG-0013 | 2026-06-30 | TASK-0013 | Task System | +1 | Created and completed the header tool search task. |
| CHG-0014 | 2026-06-30 | TASK-0013 | Documentation | +1 | Updated handoff, changelog, and task completion notes for header tool search. |
| CHG-0015 | 2026-06-30 | TASK-0014 | Plugin Framework | +1 | Restored DHCP Sleuth as a tracked standalone toolkit app and registered it in the custom tools manifest. |
| CHG-0016 | 2026-06-30 | TASK-0014 | UI | +1 | Hardened GUI smoke-test cleanup and launcher test-mode singleton handling so validation works while the toolkit is open. |
| CHG-0017 | 2026-06-30 | TASK-0014 | Task System | +1 | Created and completed the DHCP Sleuth restore task. |
| CHG-0018 | 2026-06-30 | TASK-0014 | Documentation | +1 | Updated task, handoff, and changelog records for DHCP Sleuth restoration. |
| CHG-0019 | 2026-06-30 | TASK-0015 | UI | +1 | Rebuilt header search tab mapping from the same tool placement path used by visible tab pages. |
| CHG-0020 | 2026-06-30 | TASK-0015 | Task System | +1 | Created and completed the header search tab mapping correction task. |
| CHG-0021 | 2026-06-30 | TASK-0015 | Documentation | +1 | Updated task, handoff, and changelog records for search tab mapping correction. |
| CHG-0022 | 2026-06-30 | TASK-0016 | UI | +1 | Centralized visible GUI tab tools and header search entries through one normalized tool registry path and hardened triage completion handling. |
| CHG-0023 | 2026-06-30 | TASK-0016 | Validation/Test Framework | +1 | Added button smoke-test checks for duplicate GUI registry and header search entries. |
| CHG-0024 | 2026-06-30 | TASK-0016 | Task System | +1 | Created and completed the tool source-of-truth correction task. |
| CHG-0025 | 2026-06-30 | TASK-0016 | Documentation | +1 | Updated task, handoff, and changelog records for tool source-of-truth correction. |
| CHG-0026 | 2026-07-01 | TASK-0010 | Repository Governance | +1 | Added the official task queue rule and lifecycle reference to `PROJECT.md`. |
| CHG-0027 | 2026-07-01 | TASK-0010 | Documentation | +1 | Added the Prime Directive, governance responsibilities, and handoff updates for the foundation audit. |
| CHG-0028 | 2026-07-01 | TASK-0010 | Task System | +1 | Created `docs/TASKS/QUEUE.md` and activated `TASK-0010-Foundation-Audit` for ChatGPT. |
| CHG-0029 | 2026-07-01 | TASK-0010 | Roadmap/Backlog | +1 | Established the queued-task structure that ChatGPT will use to update the backlog during the foundation audit. |
| CHG-0030 | 2026-07-01 | TASK-0010 / REVIEW-0001 | Repository Governance | reset to 0 / 10 | Reconciled governance source of truth, aligned `docs/TASKS/QUEUE.md` and `docs/HANDOFF.md`, and resolved the invalid duplicate `TASK-0010-Foundation-Audit` active-state reference. |
| CHG-0031 | 2026-07-01 | TASK-0010 / REVIEW-0001 | Task System | reset to 0 / 10 | Established exactly one active task in the queue and handoff: `TASK-0017-Triage-Manual-Run-Validation`. |
| CHG-0032 | 2026-07-01 | TASK-0010 / REVIEW-0001 | Documentation | reset to 0 / 10 | Created `REVIEW-0001-Foundation-Audit` and executive project status report; refreshed handoff. |
| CHG-0033 | 2026-07-01 | TASK-0010 / REVIEW-0001 | Roadmap/Backlog | reset to 0 / 10 | Updated roadmap and backlog/task sequence for validation, HEPHAESTUS Local Analysis Engine design, and later implementation. |
