# Change Ledger

This ledger records accepted engineering changes that increment subsystem audit counters. Detailed prior history remains preserved in immutable Git history and individual task records.

A subsystem counter reaching `25 / 25` triggers automatic Codex Audit Preparation followed by Project Custodian Engineering Audit. Only the audited subsystem counter resets unless explicitly authorized otherwise.

## Current Counters

| Subsystem | Current Counter | Last Material Change |
|---|---:|---|
| Repository Governance | 11 / 25 | Autonomous Resume Work and two-stage audit cycle. |
| Architecture | 6 / 25 | TASK-0087 parser-backed evidence and event-time contracts. |
| Documentation | 5 / 25 | Autonomous-cycle policy and audit preparation template. |
| Task System | 11 / 25 | Codex continuous queue progression and automatic audit-task transition. |
| Evidence Collection and Deterministic Analysis | 6 / 25 | TASK-0087 parser-backed quality and structured error artifacts. |
| ARGUS | 8 / 25 | TASK-0087 parser-failure and timestamp confidence handling. |
| Reporting | 3 / 25 | TASK-0086 run/bundle identity reporting. |
| UI | 23 / 25 | TASK-0086 Analyze workflow bundle selection. |
| Plugin Framework | 1 / 25 | No recent material change. |
| Build System | 19 / 25 | TASK-0087 build metadata. |
| Validation/Test Framework | 0 / 25 | TASK-0101 threshold audit completed. |
| Roadmap/Backlog | 17 / 25 | Release-blocking remediation resumed with TASK-0088. |

## Current Ledger Entries

| Change ID | Date | Task | Subsystem | Counter Change | Description |
|---|---|---|---|---:|---|
| CHG-GOV-0092 | 2026-07-12 | Governance maintenance | Repository Governance | +1 | Authorized one `Resume Work` instruction to continue through dependency-ready Codex tasks until an audit, Project Custodian, blocker, or user-only boundary. |
| CHG-DOC-0092 | 2026-07-12 | Governance maintenance | Documentation | +1 | Added the autonomous work/audit policy and reusable Audit Preparation template. |
| CHG-TASK-0092 | 2026-07-12 | Governance maintenance | Task System | +1 | Authorized Codex to activate the next ordered Codex task and automatically create/complete Audit Preparation before transferring to Project Custodian Engineering Audit. |
| CHG-GOV-0091 | 2026-07-12 | Governance maintenance | Repository Governance | +1 | Required `Resume Work` to fetch and verify authoritative remote state before execution. |
| CHG-0084-01 | 2026-07-12 | TASK-0084 | Repository Governance | +1 | Closed the full codebase audit and transferred ownership to remediation. |
| CHG-0084-02 | 2026-07-12 | TASK-0084 | Architecture | +1 | Established the dependency-ordered remediation architecture. |
| CHG-0084-03 | 2026-07-12 | TASK-0084 | Documentation | +1 | Completed audit reports and readiness assessment. |
| CHG-0084-04 | 2026-07-12 | TASK-0084 | Task System | +1 | Created remediation tasks and left one Active task. |
| CHG-0084-05 | 2026-07-12 | TASK-0084 | Roadmap/Backlog | +1 | Reordered remediation and release work. |
| CHG-0086-01 | 2026-07-12 | TASK-0086 | Architecture | +1 | Added validated diagnostic bundle identity and offline evidence boundary. |
| CHG-0086-02 | 2026-07-12 | TASK-0086 | Evidence Collection and Deterministic Analysis | +1 | Removed live-host contamination and propagated immutable run identity. |
| CHG-0086-03 | 2026-07-12 | TASK-0086 | ARGUS | +1 | Bound ARGUS inputs and outputs to validated run identity. |
| CHG-0086-04 | 2026-07-12 | TASK-0086 | Reporting | +1 | Added run and bundle identity to reports. |
| CHG-0086-05 | 2026-07-12 | TASK-0086 | UI | +1 | Aligned Analyze bundle selection with validated resolver. |
| CHG-0086-06 | 2026-07-12 | TASK-0086 | Build System | +1 | Updated build metadata. |
| CHG-0086-07 | 2026-07-12 | TASK-0086 | Validation/Test Framework | +1 | Added identity and isolation fixtures. |
| CHG-0086-08 | 2026-07-12 | TASK-0086 | Documentation | +1 | Recorded implementation evidence. |
| CHG-0086-09 | 2026-07-12 | TASK-0086 / TASK-0087 | Task System | +1 | Completed TASK-0086 and activated TASK-0087. |
| CHG-0086-10 | 2026-07-12 | TASK-0086 | Roadmap/Backlog | +1 | Advanced remediation. |
| CHG-0087-01 | 2026-07-12 | TASK-0087 | Architecture | +1 | Defined parser-backed evidence and source-event-time contracts. |
| CHG-0087-02 | 2026-07-12 | TASK-0087 | Evidence Collection and Deterministic Analysis | +1 | Added parser-backed quality and structured error artifacts. |
| CHG-0087-03 | 2026-07-12 | TASK-0087 | ARGUS | +1 | Added parser failure and timestamp confidence handling. |
| CHG-0087-04 | 2026-07-12 | TASK-0087 | Validation/Test Framework | +1 | Added regression fixtures, reaching `25 / 25`. |
| CHG-0087-05 | 2026-07-12 | TASK-0087 | Documentation | +1 | Recorded implementation evidence. |
| CHG-0087-06 | 2026-07-12 | TASK-0087 / TASK-0101 | Task System | +1 | Completed TASK-0087 and activated required audit. |
| CHG-0087-07 | 2026-07-12 | TASK-0087 | Build System | +1 | Updated build metadata. |
| CHG-0087-08 | 2026-07-12 | TASK-0087 / TASK-0101 | Roadmap/Backlog | +1 | Inserted threshold audit. |
| CHG-0101-01 | 2026-07-12 | TASK-0101 | Validation/Test Framework | Reset to 0 | Completed threshold audit and reset only the audited subsystem. |
| CHG-0101-02 | 2026-07-12 | TASK-0101 | Documentation | +1 | Added audit evidence report. |
| CHG-0101-03 | 2026-07-12 | TASK-0101 / TASK-0088 | Task System | +1 | Completed audit and activated TASK-0088. |
| CHG-0101-04 | 2026-07-12 | TASK-0101 / TASK-0088 | Roadmap/Backlog | +1 | Cleared validation gate and resumed remediation. |

## Audit Closeout

TASK-0085 reset Documentation only. TASK-0101 reset Validation/Test Framework only. Future threshold audits follow the autonomous two-stage cycle.
