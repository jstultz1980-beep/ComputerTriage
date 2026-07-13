# Change Ledger

This ledger records accepted engineering changes that increment subsystem audit counters. Detailed prior ledger history remains preserved in immutable Git history and individual task records.

A subsystem counter reaching `25 / 25` requires a new audit before additional implementation work continues. After an audit, only the audited subsystem counter resets unless the task explicitly authorizes broader resets.

## Current Counters

| Subsystem | Current Counter | Last Material Change |
|---|---:|---|
| Repository Governance | 10 / 25 | Mandatory remote synchronization verification added to `Resume Work`. |
| Architecture | 6 / 25 | TASK-0087 parser-backed evidence and event-time contracts. |
| Documentation | 4 / 25 | TASK-0101 validation/test audit report and evidence reconciliation. |
| Task System | 10 / 25 | TASK-0101 completion and TASK-0088 activation. |
| Evidence Collection and Deterministic Analysis | 6 / 25 | TASK-0087 parser-backed quality and structured error artifacts. |
| ARGUS | 8 / 25 | TASK-0087 parser-failure and timestamp confidence handling. |
| Reporting | 3 / 25 | TASK-0086 run/bundle identity reporting. |
| UI | 23 / 25 | TASK-0086 Analyze workflow bundle selection. |
| Plugin Framework | 1 / 25 | No audit-closeout implementation change. |
| Build System | 19 / 25 | TASK-0087 build metadata. |
| Validation/Test Framework | 0 / 25 | TASK-0101 threshold audit completed and reset only this subsystem. |
| Roadmap/Backlog | 17 / 25 | Release-blocking remediation resumed with TASK-0088. |

## Current Ledger Entries

| Change ID | Date | Task | Subsystem | Counter Change | Description |
|---|---|---|---|---:|---|
| CHG-GOV-0091 | 2026-07-12 | Governance maintenance | Repository Governance | +1 | Required `Resume Work` to fetch the authoritative remote, compare local/upstream divergence, safely synchronize before reading Active-task state, and stop through Error Handoff when synchronization is unsafe or impossible. |
| CHG-0084-01 | 2026-07-12 | TASK-0084 | Repository Governance | +1 | Closed the full codebase audit, confirmed GitHub source-of-truth and admin write access, and transferred ownership to the first remediation task. |
| CHG-0084-02 | 2026-07-12 | TASK-0084 | Architecture | +1 | Completed architecture compliance assessment and established the dependency-ordered remediation architecture. |
| CHG-0084-03 | 2026-07-12 | TASK-0084 | Documentation | +1 | Completed the Findings Register, Technical Debt Register, Repository Health Assessment, Executive Engineering Report, and Release Readiness Assessment. |
| CHG-0084-04 | 2026-07-12 | TASK-0084 | Task System | +1 | Created focused TASK-0086 through TASK-0100 records, removed superseded queue entries, and left exactly one Active task. |
| CHG-0084-05 | 2026-07-12 | TASK-0084 | Roadmap/Backlog | +1 | Reordered all remaining work into the accepted dependency-based remediation and release sequence. |
| CHG-0086-01 | 2026-07-12 | TASK-0086 | Architecture | +1 | Added the shared validated diagnostic bundle identity and offline source-evidence boundary. |
| CHG-0086-02 | 2026-07-12 | TASK-0086 | Evidence Collection and Deterministic Analysis | +1 | Removed live-host contamination, rejected invalid roots, excluded generated outputs, and propagated immutable run identity. |
| CHG-0086-03 | 2026-07-12 | TASK-0086 | ARGUS | +1 | Required ARGUS inputs and outputs to match the validated run and bundle identity. |
| CHG-0086-04 | 2026-07-12 | TASK-0086 | Reporting | +1 | Added run and bundle identity to deterministic and ARGUS reports. |
| CHG-0086-05 | 2026-07-12 | TASK-0086 | UI | +1 | Aligned Analyze workflow bundle selection with the validated default resolver. |
| CHG-0086-06 | 2026-07-12 | TASK-0086 | Build System | +1 | Updated build metadata for evidence isolation and bundle identity remediation. |
| CHG-0086-07 | 2026-07-12 | TASK-0086 | Validation/Test Framework | +1 | Added cross-machine, invalid-root, mixed-export, idempotence, ARGUS, and transfer identity fixtures. |
| CHG-0086-08 | 2026-07-12 | TASK-0086 | Documentation | +1 | Recorded TASK-0086 implementation and validation evidence. |
| CHG-0086-09 | 2026-07-12 | TASK-0086 / TASK-0087 | Task System | +1 | Completed TASK-0086 and activated TASK-0087 in remediation order. |
| CHG-0086-10 | 2026-07-12 | TASK-0086 | Roadmap/Backlog | +1 | Advanced release-blocking remediation to parser-backed evidence quality and timeline semantics. |
| CHG-0087-01 | 2026-07-12 | TASK-0087 | Architecture | +1 | Defined parser-backed evidence-quality and source-event-time timeline contracts. |
| CHG-0087-02 | 2026-07-12 | TASK-0087 | Evidence Collection and Deterministic Analysis | +1 | Separated discovery, parsing, semantics, and coverage and emitted structured export-error envelopes. |
| CHG-0087-03 | 2026-07-12 | TASK-0087 | ARGUS | +1 | Downgraded evidence quality for parser failures and tied timeline confidence to source-event-time semantics. |
| CHG-0087-04 | 2026-07-12 | TASK-0087 | Validation/Test Framework | +1 | Added parser-quality, safe-export, event/copy timestamp, and ARGUS confidence regression fixtures, reaching 25 / 25. |
| CHG-0087-05 | 2026-07-12 | TASK-0087 | Documentation | +1 | Recorded TASK-0087 implementation and validation evidence. |
| CHG-0087-06 | 2026-07-12 | TASK-0087 / TASK-0101 | Task System | +1 | Completed TASK-0087 and activated the required Validation/Test Framework threshold audit. |
| CHG-0087-07 | 2026-07-12 | TASK-0087 | Build System | +1 | Updated build metadata for parser-backed evidence quality and event-time semantics. |
| CHG-0087-08 | 2026-07-12 | TASK-0087 / TASK-0101 | Roadmap/Backlog | +1 | Inserted the required threshold audit before TASK-0088. |
| CHG-0101-01 | 2026-07-12 | TASK-0101 | Validation/Test Framework | Reset to 0 | Audited executable validation, reconciled recent claims, mapped remaining gaps to focused tasks, and reset only the audited subsystem. |
| CHG-0101-02 | 2026-07-12 | TASK-0101 | Documentation | +1 | Added the validation/test framework audit report and recorded executable evidence. |
| CHG-0101-03 | 2026-07-12 | TASK-0101 / TASK-0088 | Task System | +1 | Completed the required audit and activated TASK-0088. |
| CHG-0101-04 | 2026-07-12 | TASK-0101 / TASK-0088 | Roadmap/Backlog | +1 | Cleared the validation gate and resumed dependency-ordered remediation. |

## Audit Closeout

TASK-0084 was a broad planned engineering audit, not a threshold-triggered subsystem reset. It did not reset subsystem counters. TASK-0085 reset Documentation only. TASK-0101 reset Validation/Test Framework only.

Historical ledger entries before TASK-0084 remain available in Git history.
