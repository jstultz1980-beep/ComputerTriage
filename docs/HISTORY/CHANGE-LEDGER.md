# Change Ledger

This ledger records accepted engineering changes that increment subsystem audit counters. Detailed prior history remains preserved in immutable Git history and individual task records.

A subsystem counter reaching `25 / 25` triggers automatic Codex Audit Preparation followed by Project Custodian Engineering Audit. Only the audited subsystem counter resets unless explicitly authorized otherwise.

## Current Counters

| Subsystem | Current Counter | Last Material Change |
|---|---:|---|
| Repository Governance | 13 / 25 | Lightweight `Governance Refresh` command. |
| Architecture | 11 / 25 | TASK-0092 staged-image and deployment transaction contract. |
| Documentation | 12 / 25 | TASK-0092 implementation and validation evidence. |
| Task System | 17 / 25 | TASK-0092 completion and TASK-0093 activation. |
| Evidence Collection and Deterministic Analysis | 8 / 25 | TASK-0089 final bundle integrity and collection outcomes. |
| ARGUS | 10 / 25 | TASK-0090 citation, classification, priority, and confidence correctness. |
| Reporting | 3 / 25 | TASK-0086 run/bundle identity reporting. |
| UI | 0 / 25 | TASK-0103 Engineering Audit accepted and reset only UI. |
| Plugin Framework | 3 / 25 | TASK-0091 print and remote transaction behavior. |
| Build System | 24 / 25 | TASK-0092 managed-image and transactional deploy/update integrity. |
| Validation/Test Framework | 5 / 25 | TASK-0092 payload, interruption, identity, swap, and rollback fixtures. |
| Roadmap/Backlog | 22 / 25 | Remediation advanced to TASK-0093. |

## Current Ledger Entries

| Change ID | Date | Task | Subsystem | Counter Change | Description |
|---|---|---|---|---:|---|
| CHG-0103-01 | 2026-07-12 | TASK-0103 | UI | Reset to 0 | Accepted the TASK-0102 UI audit package, retained TASK-0096 and TASK-0099 as remediation owners, and reset only UI. |
| CHG-0103-02 | 2026-07-12 | TASK-0103 / TASK-0092 | Task System | 0 | Closed the Project Custodian audit boundary and activated TASK-0092 without incrementing the counter for routine audit bookkeeping. |
| CHG-GOV-0094 | 2026-07-12 | Governance maintenance | Repository Governance | +1 | Added the lightweight `Governance Refresh` command so Codex can safely reload current governance during an Active task and resume without a full restart. |
| CHG-DOC-0094 | 2026-07-12 | Governance maintenance | Documentation | +1 | Added `docs/GOVERNANCE/GOVERNANCE-REFRESH.md` and registered the command in PROJECT.md, AGENTS.md, and Codex operating instructions. |
| CHG-GOV-0093 | 2026-07-12 | Governance maintenance | Repository Governance | +1 | Required every Codex stop-boundary summary to end with the exact operator instruction `Tell Debbie to continue`, or `Tell Debbie to address errors` for a genuine blocker, with no trailing text. |
| CHG-DOC-0093 | 2026-07-12 | Governance maintenance | Documentation | +1 | Updated authoritative workflow files with the mandatory closing instruction. |
| CHG-GOV-0092 | 2026-07-12 | Governance maintenance | Repository Governance | +1 | Authorized one `Resume Work` instruction to continue through dependency-ready Codex tasks until an audit, Project Custodian, blocker, or user-only boundary. |
| CHG-DOC-0092 | 2026-07-12 | Governance maintenance | Documentation | +1 | Added the autonomous work/audit policy and reusable Audit Preparation template. |
| CHG-TASK-0092 | 2026-07-12 | Governance maintenance | Task System | +1 | Authorized Codex to activate the next ordered Codex task and automatically create/complete Audit Preparation before transferring to Project Custodian Engineering Audit. |
| CHG-GOV-0091 | 2026-07-12 | Governance maintenance | Repository Governance | +1 | Required `Resume Work` to fetch and verify authoritative remote state before execution. |
| CHG-0101-01 | 2026-07-12 | TASK-0101 | Validation/Test Framework | Reset to 0 | Completed threshold audit and reset only the audited subsystem. |
| CHG-0091-01 | 2026-07-12 | TASK-0091 | Architecture | +1 | Added the capture/apply/verify/rollback transaction contract. |
| CHG-0091-02 | 2026-07-12 | TASK-0091 | UI | +1 | Added transaction-aware print failure and recovery status, reaching 25 / 25. |
| CHG-0091-03 | 2026-07-12 | TASK-0091 | Plugin Framework | +1 | Added print and remote service/firewall rollback behavior. |
| CHG-0091-04 | 2026-07-12 | TASK-0091 | Validation/Test Framework | +1 | Added rollback, partial-change, locked-file, service-failure, and cancellation fixtures. |
| CHG-0091-05 | 2026-07-12 | TASK-0091 | Build System | +1 | Updated build metadata. |
| CHG-0091-06 | 2026-07-12 | TASK-0091 / TASK-0102 / TASK-0103 | Task System | +2 | Completed TASK-0091, prepared the UI audit, and activated Project Custodian review. |
| CHG-0091-07 | 2026-07-12 | TASK-0091 / TASK-0102 | Documentation | +1 | Recorded implementation and UI audit evidence. |
| CHG-0091-08 | 2026-07-12 | TASK-0102 / TASK-0103 | Roadmap/Backlog | +1 | Inserted required UI Engineering Audit before TASK-0092. |
| CHG-0092-01 | 2026-07-12 | TASK-0092 | Architecture | +1 | Added complete managed-image and staged directory-swap contracts. |
| CHG-0092-02 | 2026-07-12 | TASK-0092 | Build System | +1 | Added managed manifests, identity validation, staged verification, atomic replacement, and rollback. |
| CHG-0092-03 | 2026-07-12 | TASK-0092 | Validation/Test Framework | +1 | Added missing/corrupt payload, wrong destination, interruption, locked file, swap, and rollback fixtures. |
| CHG-0092-04 | 2026-07-12 | TASK-0092 | Documentation | +1 | Recorded implementation, validation, and bounded full-image performance evidence. |
| CHG-0092-05 | 2026-07-12 | TASK-0092 / TASK-0093 | Task System | +1 | Completed TASK-0092 and activated TASK-0093. |
| CHG-0092-06 | 2026-07-12 | TASK-0092 / TASK-0093 | Roadmap/Backlog | +1 | Advanced remediation to external-tool provenance. |

## Audit Closeout

TASK-0085 reset Documentation only. TASK-0101 reset Validation/Test Framework only. TASK-0103 reset UI only. Future threshold audits follow the autonomous two-stage cycle.
