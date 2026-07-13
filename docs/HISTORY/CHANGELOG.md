# Changelog

Detailed historical implementation chronology remains preserved in Git history and individual task records. This file records current milestone-level changes.

## 2026-07-12

- Added a mandatory Codex completion-prompt rule: every non-blocked stop-boundary summary must end exactly with `Tell Debbie to continue`; every genuine blocker summary must end exactly with `Tell Debbie to address errors`.
- Updated PROJECT.md, AGENTS.md, Codex operating instructions, the autonomous work cycle, and the current handoff so the closing instruction cannot be paraphrased or followed by additional text.
- Established the autonomous `Resume Work` cycle: Codex now continues through dependency-ready Codex-owned tasks without another prompt until an audit gate, Project Custodian boundary, genuine blocker, or user-only decision.
- Required Codex to automatically create and complete Audit Preparation when any subsystem reaches `25 / 25`, then push the evidence package and activate a Project Custodian Engineering Audit task.
- Added `docs/GOVERNANCE/AUTONOMOUS-WORK-AND-AUDIT-CYCLE.md` and `docs/REVIEWS/AUDIT-PREPARATION-TEMPLATE.md`.
- Defined `Continue` as the Project Custodian review instruction: review the cloud audit package, make architecture/governance decisions, reset audited counters, activate the next Codex task, push, and return `Resume Work`.
- Limited user interruption to decisions that genuinely require product preference, credentials/licensing, destructive/external action, physical access, release authorization, or explicit subjective acceptance.
- Preserved TASK-0088 as the sole Active task.
- Completed `TASK-0101-Validation-Test-Framework-Counter-Audit` and reset only Validation/Test Framework to `0 / 25`.
- Reconciled 62-script parser validation, focused identity/parser/triage/toolkit fixtures, GUI smoke, and button-smoke with recent task claims.
- Mapped remaining result, package, runtime-state, GUI-lifecycle, and repository-wide test gaps to existing TASK-0088, TASK-0092, TASK-0094, TASK-0096, and TASK-0099 rather than creating duplicates.
- Activated `TASK-0088-Canonical-Operation-Results-And-Failure-Propagation`.
- Strengthened `Resume Work` with mandatory remote synchronization and divergence checks.
- Completed TASK-0087 parser-backed evidence quality and timeline semantics.
- Completed TASK-0086 offline evidence isolation and immutable bundle identity.
- Completed TASK-0084 full codebase architecture and quality audit.

## 2026-07-10

- Completed TASK-0073 ARGUS evidence normalization.
- Completed TASK-0074 event grouping and technician recommendations.
- Completed TASK-0075 technician and escalation reporting.
- Completed TASK-0076 guided Analyze workflow integration.
- Completed TASK-0085 Documentation counter audit.

## Earlier History

Earlier detailed changes remain in individual task files, the change ledger, and immutable Git history.