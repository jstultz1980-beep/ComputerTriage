# Change Ledger

This ledger records accepted engineering changes that increment subsystem audit counters. Detailed prior history remains preserved in immutable Git history and individual task records.

A subsystem counter reaching `25 / 25` triggers automatic Codex Audit Preparation followed by Project Custodian Engineering Audit. Only the audited subsystem counter resets unless explicitly authorized otherwise.

## Current Counters

| Subsystem | Current Counter | Last Material Change |
|---|---:|---|
| Repository Governance | 15 / 25 | TASK-0097 focused procedure-reference consolidation. |
| Architecture | 19 / 25 | TASK-0100 structured timing and run-scoped observation/provider contract. |
| Documentation | 24 / 25 | TASK-0111 remediation evidence, release-candidate guidance, and resolved known limitations. |
| Task System | 8 / 25 | TASK-0113 release closeout and queue handoff to the Project Custodian. |
| Evidence Collection and Deterministic Analysis | 10 / 25 | TASK-0095 canonical HEPHAESTUS analysis ownership. |
| ARGUS | 10 / 25 | TASK-0090 citation, classification, priority, and confidence correctness. |
| Reporting | 5 / 25 | TASK-0098 canonical metadata, escaping, and run-linked artifact state. |
| UI | 5 / 25 | TASK-0112 queued warm-up, per-stage timing, and navigation responsiveness. |
| Plugin Framework | 6 / 25 | TASK-0095 plugin discovery, compatibility, lifecycle, and isolation contract. |
| Build System | 8 / 25 | TASK-0112 GUI warm-up helper integration and build metadata refresh. |
| Validation/Test Framework | 15 / 25 | TASK-0112 warm-up controller and performance/cache validation. |
| Roadmap/Backlog | 11 / 25 | Advanced to Version 1.0 release closeout and Project Custodian confirmation. |

## Current Ledger Entries

| Change ID | Date | Task | Subsystem | Counter Change | Description |
|---|---|---|---|---:|---|
| CHG-0113-01 | 2026-07-14 | TASK-0113 | Task System | +1 | Closed the Codex release-publication task and handed control back to the Project Custodian. |
| CHG-0113-02 | 2026-07-14 | TASK-0113 | Roadmap/Backlog | +1 | Advanced the roadmap from release authorization to published release closeout. |
| CHG-0112-01 | 2026-07-14 | TASK-0112 | UI | +1 | Added queued tab warm-up, per-stage first-open timing, and safe user-priority handling for cold navigation. |
| CHG-0112-02 | 2026-07-14 | TASK-0112 | Build System | +1 | Added the GUI warm-up helper and refreshed toolkit build metadata for the accepted performance remediation. |
| CHG-0112-03 | 2026-07-14 | TASK-0112 | Validation/Test Framework | +1 | Added the focused warm-up controller fixture and updated performance/cache validation to require stage timings. |
| CHG-0112-04 | 2026-07-14 | TASK-0112 | Task System | +1 | Completed TASK-0112 and returned the release boundary to the Project Custodian decision. |
| CHG-0112-05 | 2026-07-14 | TASK-0112 | Roadmap/Backlog | +1 | Advanced the sequence back to the final release-readiness review. |
| CHG-0111-01 | 2026-07-14 | TASK-0111 | Build System | +1 | Added fail-closed long-path cleanup helpers to the production-package builder and preserved the package metadata update. |
| CHG-0111-02 | 2026-07-14 | TASK-0111 | Validation/Test Framework | +1 | Added a focused mutable-tree cleanup fixture and verified the clean full production image. |
| CHG-0111-03 | 2026-07-14 | TASK-0111 | Documentation | +1 | Recorded the remediation outcome, resolved the known limitation, and updated release guidance. |
| CHG-0111-04 | 2026-07-14 | TASK-0111 | Task System | +1 | Returned the Active task boundary to the Project Custodian release-readiness decision. |
| CHG-0111-05 | 2026-07-14 | TASK-0111 | Roadmap/Backlog | +1 | Advanced the remaining sequence from remediation to final release readiness review. |
| CHG-0080-01 | 2026-07-13 | TASK-0080 | Validation/Test Framework | +1 | Ran the 18-stage canonical gate and independently built and verified the 6.72 GB production image. |
| CHG-0080-02 | 2026-07-13 | TASK-0080 | Documentation | +1 | Recorded release evidence, quick-start guidance, readiness status, build duration, and the LibreOffice cleanup limitation. |
| CHG-0080-03 | 2026-07-13 | TASK-0080 | Task System | +1 | Completed Codex release-gate execution and transferred the Active task to the Project Custodian decision boundary. |
| CHG-0080-04 | 2026-07-13 | TASK-0080 | Roadmap/Backlog | +1 | Advanced the final gate to remediation/risk-acceptance and release-readiness disposition. |
| CHG-0100-01 | 2026-07-13 | TASK-0100 | Architecture | +1 | Added nested performance-run, budget, observation freshness, provider-health, invalidation, and telemetry contracts. |
| CHG-0100-02 | 2026-07-13 | TASK-0100 | UI | +1 | Emitted structured GUI shell, first-render, and every-tab-switch timing. |
| CHG-0100-03 | 2026-07-13 | TASK-0100 | Build System | +1 | Instrumented managed-file hashing and updated build metadata. |
| CHG-0100-04 | 2026-07-13 | TASK-0100 | Validation/Test Framework | +1 | Added cold/warm, cache reuse, provider failure, cross-run retry, invalidation, and budget fixtures. |
| CHG-0100-05 | 2026-07-13 | TASK-0100 | Documentation | +1 | Documented performance budgets, cache safety, telemetry, and workstation baselines. |
| CHG-0100-06 | 2026-07-13 | TASK-0100 / TASK-0080 | Task System | +1 | Completed performance remediation and activated the final release-candidate gate. |
| CHG-0100-07 | 2026-07-13 | TASK-0100 / TASK-0080 | Roadmap/Backlog | +1 | Advanced from architecture stabilization to release-candidate validation. |
| CHG-0099-01 | 2026-07-13 | TASK-0099 | Architecture | +1 | Established one manifest-driven repository validation entry point with coverage and fixture-completeness enforcement. |
| CHG-0099-02 | 2026-07-13 | TASK-0099 | Validation/Test Framework | +1 | Added all-tracked-file 5.1 parsing, isolated stages, timeouts, negative-path coverage, load completeness, and JSON results. |
| CHG-0099-03 | 2026-07-13 | TASK-0099 | Build System | +1 | Added valid/tampered production-package verification and updated toolkit build metadata. |
| CHG-0099-04 | 2026-07-13 | TASK-0099 | Documentation | +1 | Documented the canonical validation contract and recorded the 17-stage pass. |
| CHG-0099-05 | 2026-07-13 | TASK-0099 / TASK-0100 | Task System | +1 | Completed repository validation work and activated performance instrumentation. |
| CHG-0099-06 | 2026-07-13 | TASK-0099 / TASK-0100 | Roadmap/Backlog | +1 | Advanced architecture stabilization to performance instrumentation and observation caching. |
| CHG-0098-01 | 2026-07-13 | TASK-0098 | Architecture | +1 | Defined shared report metadata, escaping, immutable run identity, artifact record, ordering, and state contracts. |
| CHG-0098-02 | 2026-07-13 | TASK-0098 | Reporting | +1 | Integrated canonical metadata and escaping across identified report families with explicit available, stale, and missing resolution. |
| CHG-0098-03 | 2026-07-13 | TASK-0098 | Validation/Test Framework | +1 | Added snapshot, escaping, multiple-run, immutable-conflict, stale, and deleted artifact fixtures. |
| CHG-0098-04 | 2026-07-13 | TASK-0098 | Documentation | +1 | Documented the reporting and run-index contract plus complete validation evidence. |
| CHG-0098-05 | 2026-07-13 | TASK-0098 | Build System | +1 | Updated toolkit build metadata for the reporting/run-index implementation. |
| CHG-0098-06 | 2026-07-13 | TASK-0098 / TASK-0099 | Task System | +1 | Completed TASK-0098 and activated repository-wide validation work. |
| CHG-0098-07 | 2026-07-13 | TASK-0098 / TASK-0099 | Roadmap/Backlog | +1 | Advanced architecture stabilization to the repository-wide validation foundation. |
| CHG-0110-01 | 2026-07-13 | TASK-0110 | Documentation | +1 | Reconciled task aliases, terminal vocabulary, supersession, resolved Error Handoff history, and punch-list evidence. |
| CHG-0110-02 | 2026-07-13 | TASK-0110 / TASK-0098 | Task System | +1 | Completed consistency cleanup and activated TASK-0098. |
| CHG-0110-03 | 2026-07-13 | TASK-0110 / TASK-0098 | Roadmap/Backlog | +1 | Advanced the approved sequence to shared reporting and run-index contracts. |
| CHG-0109-01 | 2026-07-13 | TASK-0109 | Task System | Reset to 0 | Accepted the TASK-0108 Task System audit package, recorded all debt dispositions, and reset only Task System. |
| CHG-0109-02 | 2026-07-13 | TASK-0109 / TASK-0110 | Task System | 0 | Closed the Project Custodian audit boundary and activated focused consistency cleanup without incrementing the freshly reset counter. |
| CHG-0108-01 | 2026-07-13 | TASK-0108 | Documentation | +1 | Recorded deterministic Task System threshold evidence, validation, debt candidates, and recommended dispositions. |
| CHG-0108-02 | 2026-07-13 | TASK-0108 / TASK-0109 | Task System | 0 | Completed Audit Preparation and activated Project Custodian review without resetting or incrementing the gated counter. |
| CHG-0097-06 | 2026-07-13 | TASK-0097 | Repository Governance | +1 | Replaced duplicated entry-point procedures with authoritative workflow and audit references while retaining mandatory controls. |
| CHG-0097-07 | 2026-07-13 | TASK-0097 | Documentation | +1 | Reconciled current terminology references and removed the stale finish-plan queue as a competing sequence authority. |
| CHG-0097-08 | 2026-07-13 | TASK-0097 / TASK-0108 | Task System | +1 | Completed TASK-0097 and activated mandatory Task System Audit Preparation at `25 / 25`. |
| CHG-0097-09 | 2026-07-13 | TASK-0097 / TASK-0108 | Roadmap/Backlog | +1 | Inserted the Task System audit boundary before TASK-0098. |
| CHG-0097-01 | 2026-07-13 | TASK-0097 | Architecture | +1 | Defined intended-state runtime boundaries, canonical components, contracts, flow, and failure behavior. |
| CHG-0097-02 | 2026-07-13 | TASK-0097 | Repository Governance | +1 | Assigned one authoritative document to each governance responsibility and prohibited duplicated procedure text. |
| CHG-0097-03 | 2026-07-13 | TASK-0097 | Documentation | +1 | Recorded the Project Custodian decision, expanded the architecture authority, and made the roadmap forward-looking. |
| CHG-0097-04 | 2026-07-13 | TASK-0097 | Task System | +1 | Transferred the Active task to narrowly scoped Codex documentation/reference support. |
| CHG-0097-05 | 2026-07-13 | TASK-0097 | Roadmap/Backlog | +1 | Confirmed TASK-0097, TASK-0098, TASK-0099, TASK-0100, and TASK-0080 as the remaining sequence. |
| CHG-0096-01 | 2026-07-13 | TASK-0096 | Architecture | +1 | Centralized process, job, timer, timeout, cancellation, completion, and cleanup ownership. |
| CHG-0096-02 | 2026-07-13 | TASK-0096 | UI | +1 | Migrated Analyze and Triage to the shared lifecycle controller while preserving GUI behavior. |
| CHG-0096-03 | 2026-07-13 | TASK-0096 | Validation/Test Framework | +1 | Added repeated replacement, cancel, close, timeout, failure, partial, success, process, job, and timer cleanup fixtures. |
| CHG-0096-04 | 2026-07-13 | TASK-0096 | Build System | +1 | Updated toolkit build metadata for the accepted controller extraction. |
| CHG-0096-05 | 2026-07-13 | TASK-0096 / TASK-0097 | Task System | +1 | Completed TASK-0096 and activated the TASK-0097 Project Custodian boundary. |
| CHG-0096-06 | 2026-07-13 | TASK-0096 / TASK-0097 | Roadmap/Backlog | +1 | Advanced architecture stabilization to architecture, terminology, and governance consolidation. |
| CHG-0107-01 | 2026-07-13 | TASK-0107 | Roadmap/Backlog | Reset to 0 | Accepted the TASK-0106 Roadmap/Backlog audit package, confirmed remaining sequence, clarified TASK-0097 ownership, and reset only Roadmap/Backlog. |
| CHG-0107-02 | 2026-07-13 | TASK-0107 / TASK-0096 | Task System | 0 | Closed the Project Custodian audit boundary and activated TASK-0096 without incrementing the counter for routine audit bookkeeping. |
| CHG-0095-01 | 2026-07-13 | TASK-0095 | Architecture | +1 | Established canonical analysis roles, normalized tool descriptors, plugin contracts, manifest roles, and operation states. |
| CHG-0095-02 | 2026-07-13 | TASK-0095 | Evidence Collection and Deterministic Analysis | +1 | Removed duplicate HEPHAESTUS symbols and assigned authoritative deterministic analysis ownership. |
| CHG-0095-03 | 2026-07-13 | TASK-0095 | UI | +1 | Drove GUI tabs, search, and launch registry from canonical tool descriptors. |
| CHG-0095-04 | 2026-07-13 | TASK-0095 | Plugin Framework | +1 | Enforced discovery, compatibility, enablement, lifecycle, and failure isolation. |
| CHG-0095-05 | 2026-07-13 | TASK-0095 | Build System | +1 | Validated package/trust metadata through normalized external descriptors and updated build metadata. |
| CHG-0095-06 | 2026-07-13 | TASK-0095 | Validation/Test Framework | +1 | Added duplicate-symbol, descriptor, plugin, operation-state, analysis-role, GUI, and regression checks. |
| CHG-0095-07 | 2026-07-13 | TASK-0095 / TASK-0106 | Documentation | +1 | Documented canonical contracts and Roadmap/Backlog audit evidence. |
| CHG-0095-08 | 2026-07-13 | TASK-0095 / TASK-0106 / TASK-0107 | Task System | +2 | Completed architecture work, prepared the roadmap audit, and activated Project Custodian review. |
| CHG-0095-09 | 2026-07-13 | TASK-0106 / TASK-0107 | Roadmap/Backlog | +1 | Reconciled remaining task order and reached the 25 / 25 audit boundary. |
| CHG-0094-01 | 2026-07-13 | TASK-0094 | Architecture | +1 | Defined artifact ownership, retention, transfer, immutable program, and writable Runtime contracts. |
| CHG-0094-02 | 2026-07-13 | TASK-0094 | Evidence Collection and Deterministic Analysis | +1 | Added classified selective evidence transfer with verification and encryption. |
| CHG-0094-03 | 2026-07-13 | TASK-0094 | Reporting | +1 | Masked licensing reports by default and classified unmasked exports Sensitive. |
| CHG-0094-04 | 2026-07-13 | TASK-0094 | UI | +1 | Added explicit audited reveal, clipboard, and unmasked export confirmation. |
| CHG-0094-05 | 2026-07-13 | TASK-0094 | Plugin Framework | +1 | Integrated shared artifact metadata and atomic state utilities. |
| CHG-0094-06 | 2026-07-13 | TASK-0094 | Build System | +1 | Replaced folder-name cleanup with an explicit mutable-path policy and Runtime layout. |
| CHG-0094-07 | 2026-07-13 | TASK-0094 | Validation/Test Framework | +1 | Added mask, reveal, retention, transfer, interruption, concurrency, and separation fixtures. |
| CHG-0094-08 | 2026-07-13 | TASK-0094 | Documentation | +1 | Documented sensitive artifact and runtime-state policy. |
| CHG-0094-09 | 2026-07-13 | TASK-0094 / TASK-0095 | Task System | +1 | Completed TASK-0094 and activated TASK-0095. |
| CHG-0094-10 | 2026-07-13 | TASK-0094 / TASK-0095 | Roadmap/Backlog | +1 | Advanced from release-blocking remediation into architecture stabilization. |
| CHG-0105-01 | 2026-07-13 | TASK-0105 | Build System | Reset to 0 | Accepted the TASK-0104 Build System audit package, retained TASK-0100 as performance remediation owner, and reset only Build System. |
| CHG-0105-02 | 2026-07-13 | TASK-0105 / TASK-0094 | Task System | 0 | Closed the Project Custodian audit boundary and activated TASK-0094 without incrementing the counter for routine audit bookkeeping. |
| CHG-0093-01 | 2026-07-12 | TASK-0093 | Architecture | +1 | Added the external-tool provenance, integrity, lifecycle, licensing, privilege, and EDR trust contract. |
| CHG-0093-02 | 2026-07-12 | TASK-0093 | Plugin Framework | +1 | Blocked external-tool resolution and launch unless tracked trust checks pass. |
| CHG-0093-03 | 2026-07-12 | TASK-0093 | Build System | +1 | Enforced the reviewed Sysinternals production package allowlist, reaching 25 / 25. |
| CHG-0093-04 | 2026-07-12 | TASK-0093 | Validation/Test Framework | +1 | Added hash, signature, missing, expired, local classification, and EULA fixtures. |
| CHG-0093-05 | 2026-07-12 | TASK-0093 / TASK-0104 / TASK-0105 | Task System | +2 | Completed remediation, prepared the Build audit, and activated Project Custodian review. |
| CHG-0093-06 | 2026-07-12 | TASK-0093 / TASK-0104 | Documentation | +1 | Recorded provenance, retention, validation, and Build audit evidence. |
| CHG-0093-07 | 2026-07-12 | TASK-0104 / TASK-0105 | Roadmap/Backlog | +1 | Inserted the required Build System audit before TASK-0094. |
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

TASK-0085 reset Documentation only. TASK-0101 reset Validation/Test Framework only. TASK-0103 reset UI only. TASK-0105 reset Build System only. TASK-0107 reset Roadmap/Backlog only. TASK-0109 reset Task System only. Future threshold audits follow the autonomous two-stage cycle.
