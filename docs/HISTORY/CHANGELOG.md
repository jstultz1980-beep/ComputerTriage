# Changelog

Detailed historical implementation chronology remains preserved in Git history and individual task records. This file records current milestone-level changes.

## 2026-07-12

- Strengthened the Codex `Resume Work` protocol to require `git fetch --prune origin`, explicit local/upstream divergence checks, safe fast-forward synchronization, and confirmation that the local checkout matches the authoritative remote branch before Active-task execution.
- Required Codex to stop and use the Error Handoff Procedure when fetch fails, no upstream exists, branches diverge, local commits are ahead unexpectedly, or synchronization would overwrite preserved work.
- Completed `TASK-0086-Offline-Evidence-Isolation-And-Bundle-Identity`.
- Added validated immutable run/bundle identity, rejected invalid/default roots, removed live-host contamination, excluded generated outputs, and propagated identity through deterministic analysis, ARGUS, reports, GUI selection, and client-data transfer.
- Added cross-machine, mixed-export, invalid-root, repeated-run, ARGUS, and transfer fixtures; parser, smoke, and button-smoke validation passed.
- Activated `TASK-0087-Parser-Backed-Evidence-Quality-And-Timeline`.
- Completed `TASK-0084-Full-Codebase-Architecture-And-Quality-Audit`.
- Completed the Findings Register, Technical Debt Register, Repository Health Assessment, Executive Engineering Report, and Release Readiness Assessment.
- Assigned repository health score `52 / 100` and release decision `Not Ready for Release Candidate`.
- Verified every Critical and High finding has a focused remediation task or documented disposition.
- Created the complete remediation task set through TASK-0100.
- Superseded TASK-0077 with TASK-0096/TASK-0100, TASK-0078 with TASK-0093, and TASK-0079 with TASK-0092.
- Retained TASK-0080 as the final release-candidate validation and documentation gate.
- Reordered the queue into a dependency-based remediation sequence.
- Closed TASK-0084 and activated `TASK-0086-Offline-Evidence-Isolation-And-Bundle-Identity` as the only Active task.
- Updated handoff, queue, roadmap, task records, history, and audit counters.
- No application code was changed during the audit.

## 2026-07-10

- Completed TASK-0073 ARGUS evidence normalization.
- Completed TASK-0074 event grouping and technician recommendations.
- Completed TASK-0075 technician and escalation reporting.
- Completed TASK-0076 guided Analyze workflow integration.
- Completed TASK-0085 Documentation counter audit and reset Documentation to `0 / 25`.
- Activated TASK-0084 full-codebase architecture and quality audit.

## Earlier History

Earlier detailed changes remain in:
- Individual files under `docs/TASKS/`.
- `docs/HISTORY/CHANGE-LEDGER.md`.
- Immutable Git commit history.
