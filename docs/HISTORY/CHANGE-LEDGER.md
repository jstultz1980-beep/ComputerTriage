# Change Ledger

This ledger records accepted engineering changes that increment subsystem audit counters. Detailed prior history remains preserved in immutable Git history and individual task records.

A subsystem counter reaching `25 / 25` triggers automatic Codex Audit Preparation followed by Project Custodian Engineering Audit. Only the audited subsystem counter resets unless explicitly authorized otherwise.

## Current Counters

| Subsystem | Current Counter | Last Material Change |
|---|---:|---|
| Repository Governance | 13 / 25 | Lightweight `Governance Refresh` command. |
| Architecture | 10 / 25 | TASK-0091 change transaction contract. |
| Documentation | 11 / 25 | TASK-0091 evidence and TASK-0102 audit package. |
| Task System | 16 / 25 | TASK-0091 closeout and TASK-0102/TASK-0103 audit transition. |
| Evidence Collection and Deterministic Analysis | 8 / 25 | TASK-0089 final bundle integrity and collection outcomes. |
| ARGUS | 10 / 25 | TASK-0090 citation, classification, priority, and confidence correctness. |
| Reporting | 3 / 25 | TASK-0086 run/bundle identity reporting. |
| UI | 25 / 25 | TASK-0091 transaction-aware print status/recovery; Engineering Audit required. |
| Plugin Framework | 3 / 25 | TASK-0091 print and remote transaction behavior. |
| Build System | 23 / 25 | TASK-0091 build metadata. |
| Validation/Test Framework | 4 / 25 | TASK-0091 rollback, partial-change, service failure, and cancellation fixtures. |
| Roadmap/Backlog | 21 / 25 | UI audit inserted before TASK-0092. |

## Current Ledger Entries

| Change ID | Date | Task | Subsystem | Counter Change | Description |
|---|---|---|---|---:|---|
| CHG-GOV-0094 | 2026-07-12 | Governance maintenance | Repository Governance | +1 | Added the lightweight `Governance Refresh` command so Codex can safely reload current governance during an Active task and resume without a full restart. |
| CHG-DOC-0094 | 2026-07-12 | Governance maintenance | Documentation | +1 | Added `docs/GOVERNANCE/GOVERNANCE-REFRESH.md` and registered the command in PROJECT.md, AGENTS.md, and Codex operating instructions. |
| CHG-GOV-0093 | 2026-07-12 | Governance maintenance | Repository Governance | +1 | Required every Codex stop-boundary summary to end with the exact operator instruction `Tell Debbie to continue`, or `Tell Debbie to address errors` for a genuine blocker, with no trailing text. |
| CHG-DOC-0093 | 2026-07-12 | Governance maintenance | Documentation | +1 | Updated authoritative workflow files with the mandatory closing instruction. |
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
| CHG-0088-01 | 2026-07-12 | TASK-0088 | Architecture | +1 | Added the canonical operation-result schema, terminal states, and exit-code mapping. |
| CHG-0088-02 | 2026-07-12 | TASK-0088 | Evidence Collection and Deterministic Analysis | +1 | Propagated canonical states through triage and deterministic analysis. |
| CHG-0088-03 | 2026-07-12 | TASK-0088 | ARGUS | +1 | Failed closed and suppressed recommendations after contract failure. |
| CHG-0088-04 | 2026-07-12 | TASK-0088 | UI | +1 | Made safe-runner completion text depend on canonical exit state. |
| CHG-0088-05 | 2026-07-12 | TASK-0088 | Plugin Framework | +1 | Added per-step repair outcome propagation. |
| CHG-0088-06 | 2026-07-12 | TASK-0088 | Validation/Test Framework | +1 | Added terminal-state, CLI failure, and ARGUS suppression fixtures. |
| CHG-0088-07 | 2026-07-12 | TASK-0088 | Build System | +1 | Updated accepted implementation build metadata. |
| CHG-0088-08 | 2026-07-12 | TASK-0088 | Documentation | +1 | Recorded implementation and validation evidence. |
| CHG-0088-09 | 2026-07-12 | TASK-0088 / TASK-0089 | Task System | +1 | Completed TASK-0088 and activated TASK-0089. |
| CHG-0088-10 | 2026-07-12 | TASK-0088 / TASK-0089 | Roadmap/Backlog | +1 | Advanced dependency-ordered remediation to bundle integrity. |
| CHG-0089-01 | 2026-07-12 | TASK-0089 | Architecture | +1 | Defined final sidecar bundle integrity and collection outcome contracts. |
| CHG-0089-02 | 2026-07-12 | TASK-0089 | Evidence Collection and Deterministic Analysis | +1 | Added final hash verification, tamper detection, and complete collector/capability outcomes. |
| CHG-0089-03 | 2026-07-12 | TASK-0089 | Validation/Test Framework | +1 | Added integrity, tamper, nonzero, missing-executable, and failed-collector fixtures. |
| CHG-0089-04 | 2026-07-12 | TASK-0089 | Build System | +1 | Updated accepted implementation build metadata. |
| CHG-0089-05 | 2026-07-12 | TASK-0089 | Documentation | +1 | Recorded implementation and validation evidence. |
| CHG-0089-06 | 2026-07-12 | TASK-0089 / TASK-0090 | Task System | +1 | Completed TASK-0089 and activated TASK-0090. |
| CHG-0089-07 | 2026-07-12 | TASK-0089 / TASK-0090 | Roadmap/Backlog | +1 | Advanced remediation to ARGUS correctness. |
| CHG-0090-01 | 2026-07-12 | TASK-0090 | Architecture | +1 | Tightened immutable citation and confidence-bound contracts. |
| CHG-0090-02 | 2026-07-12 | TASK-0090 | ARGUS | +1 | Corrected domain matching, priority ordering, citation identity, gap isolation, and confidence bounds. |
| CHG-0090-03 | 2026-07-12 | TASK-0090 | Validation/Test Framework | +1 | Added exact-domain, all-priority, citation, and mixed-gap fixtures. |
| CHG-0090-04 | 2026-07-12 | TASK-0090 | Build System | +1 | Updated build metadata. |
| CHG-0090-05 | 2026-07-12 | TASK-0090 | Documentation | +1 | Recorded implementation evidence. |
| CHG-0090-06 | 2026-07-12 | TASK-0090 / TASK-0091 | Task System | +1 | Completed TASK-0090 and activated TASK-0091. |
| CHG-0090-07 | 2026-07-12 | TASK-0090 / TASK-0091 | Roadmap/Backlog | +1 | Advanced remediation to transaction safety. |
| CHG-0091-01 | 2026-07-12 | TASK-0091 | Architecture | +1 | Added the capture/apply/verify/rollback transaction contract. |
| CHG-0091-02 | 2026-07-12 | TASK-0091 | UI | +1 | Added transaction-aware print failure and recovery status, reaching 25 / 25. |
| CHG-0091-03 | 2026-07-12 | TASK-0091 | Plugin Framework | +1 | Added print and remote service/firewall rollback behavior. |
| CHG-0091-04 | 2026-07-12 | TASK-0091 | Validation/Test Framework | +1 | Added rollback, partial-change, locked-file, service-failure, and cancellation fixtures. |
| CHG-0091-05 | 2026-07-12 | TASK-0091 | Build System | +1 | Updated build metadata. |
| CHG-0091-06 | 2026-07-12 | TASK-0091 / TASK-0102 / TASK-0103 | Task System | +2 | Completed TASK-0091, prepared the UI audit, and activated Project Custodian review. |
| CHG-0091-07 | 2026-07-12 | TASK-0091 / TASK-0102 | Documentation | +1 | Recorded implementation and UI audit evidence. |
| CHG-0091-08 | 2026-07-12 | TASK-0102 / TASK-0103 | Roadmap/Backlog | +1 | Inserted required UI Engineering Audit before TASK-0092. |

## Audit Closeout

TASK-0085 reset Documentation only. TASK-0101 reset Validation/Test Framework only. Future threshold audits follow the autonomous two-stage cycle.
