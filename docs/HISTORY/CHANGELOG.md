# Changelog

## 2026-07-15 - Documentation Audit Closeout And Field-Test Layout Remediation

- Accepted TASK-0115 documentation-audit evidence and completed TASK-0116.
- Reset only the Documentation audit counter from `25 / 25` to `0 / 25`.
- Recorded the real-world default-launch right-side clipping defect and activated TASK-0117 for focused responsive-layout and DPI remediation.
- Kept the deferred-startup `Write-GUILog` failure outside TASK-0117 for separate tracked disposition.

## 2026-07-15 - Performance QA Instrumentation Closeout

- Completed TASK-0114 with launch-through-ReadyForUser timing, resource snapshots, shutdown/orphan checks, and Settings-only performance QA reporting.
- Captured a five-launch cold-start evidence set and preserved a technician-readable QA validation record.
- Reconciled the queue, handoff, roadmap, and build metadata for the Project Custodian review boundary.

## 2026-07-14 - Version 1.0 Release Publication

- Published the Version 1.0.0 GitHub Release from the accepted release decision at commit `38de0b626fe3cadc6848a12b9e40fadfc7006151`.
- Attached the verified `NetworkToolkit-Portable-RC-ProductionManifest.json` publication asset and recorded its SHA-256 checksum.
- Returned control to the Project Custodian for release closeout confirmation.

## 2026-07-14 - Cold-Tab Initialization Remediation

- Completed TASK-0112 cold-tab initialization performance remediation with queued warm-up and per-stage timing instrumentation.
- Canonical repository validation now passes 20 stages with zero failures.
- Focused warm-up controller validation and performance/cache probes passed.
- Returned TASK-0080 to the Project Custodian release-readiness boundary.

## 2026-07-14 - Release-Candidate Remediation

- Completed TASK-0111 long-path mutable-tree cleanup remediation and rebuilt the release candidate with fail-closed cleanup.
- Canonical repository validation now passes 19 stages with zero failures.
- Independent full-image verification now passes on the 6.73 GB production image with no mutable application data remaining.
- Returned TASK-0080 to the Project Custodian release-readiness boundary for the final release decision.

## 2026-07-13 - Release-Candidate Gate

- Completed the Codex evidence phase of TASK-0080: all 18 canonical repository validation stages passed.
- Built the complete 6.72 GB production image with 24,364 files and independently exercised its managed-file and clean-data verifier.
- Recorded a release-blocking package limitation: four long-path LibreOffice configuration files survive mutable-data cleanup, so Version 1.0 is not recommended for tagging or distribution yet.
- Updated quick-start, production-readiness, known-limitations, release evidence, handoff, and build metadata for the Project Custodian decision.

Detailed historical implementation chronology remains preserved in Git history and individual task records. This file records current milestone-level changes.

## 2026-07-13

- Completed TASK-0100 performance instrumentation and run-scoped observation caching; activated TASK-0080.
- Added structured workflow/render timing, explicit budgets, nested cache/provider-health scope, CIM/driver observation reuse, bounded optional registry crawling, and cold/warm baselines.
- Canonical repository validation now passes 18 gates with zero failures.

- Completed TASK-0099 repository-wide validation foundation and activated TASK-0100.
- Added a manifest-driven Windows PowerShell 5.1 parser/load/negative-path/package/regression runner; all 17 gates pass and all 82 tracked PowerShell files parse with zero exclusions.
- Added production-package positive/tamper fixtures and made toolkit smoke reject any import failure or degraded load.

- Completed TASK-0098 shared reporting and run-index contracts and activated TASK-0099.
- Centralized report escaping and metadata, indexed report artifacts by immutable run identity, replaced ambiguous latest ordering, and made stale/deleted artifact state explicit.
- Passed all repository fixture suites plus parser, toolkit smoke, GUI smoke, and button-smoke validation.

- Completed TASK-0110 Task System consistency cleanup and activated TASK-0098.
- Standardized current task terminal status, recorded superseded replacements, compacted the Clear Error Handoff, preserved resolved incident history, and closed plugin-modularity punch item 61.

- Completed TASK-0109 Project Custodian Task System Engineering Audit.
- Accepted the TASK-0108 evidence package and reset only Task System from `25 / 25` to `0 / 25`.
- Recorded dispositions for duplicate task identity, superseded task statuses, terminal status vocabulary, Error Handoff compaction, punch-list item 61, and transition commit granularity.
- Created and activated TASK-0110 Task System Consistency Cleanup before TASK-0098.

- Completed TASK-0108 Task System Audit Preparation and activated TASK-0109 Project Custodian Engineering Audit without resetting the `25 / 25` counter.
- Validated current task-state and runtime baselines and recorded duplicate IDs, stale queued statuses, status vocabulary, Error Handoff, punch-list, and transition-granularity debt candidates.

- Completed TASK-0097 terminology/reference reconciliation and governance simulations; Task System reached `25 / 25` and TASK-0108 Audit Preparation became active before TASK-0098.
- Reconciled the charter and current ADR references, retired the stale finish-plan queue as an authority, and reduced duplicated Codex entry-point procedure text.

- Recorded the TASK-0097 Project Custodian intended-state architecture, canonical terminology, governance authority boundaries, and approved remaining sequence.
- Expanded `docs/ARCHITECTURE.md` into the concise runtime authority and converted `docs/ROADMAP.md` to forward-looking work only.
- Authorized Codex for focused terminology/reference reconciliation and governance simulations without application or feature changes.

- Completed TASK-0096 shared GUI background operation lifecycle controller and activated the TASK-0097 Project Custodian architecture/governance boundary.
- Migrated Analyze and Triage to centralized process, job, timer, timeout, cancellation, completion-state, and cleanup ownership with focused leak fixtures.

- Completed TASK-0107 Project Custodian Roadmap/Backlog Engineering Audit.
- Accepted the TASK-0106 evidence package and reset only Roadmap/Backlog from `25 / 25` to `0 / 25`.
- Confirmed the remaining sequence: TASK-0096, TASK-0097, TASK-0098, TASK-0099, TASK-0100, TASK-0080.
- Clarified that TASK-0097 begins with a Project Custodian architecture/governance decision and uses Codex only for explicitly authorized implementation-reference updates.
- Activated TASK-0096 GUI Background Operation Controller Extraction for Codex.

- Completed TASK-0094 sensitive artifact handling and runtime-state safety; activated TASK-0095.
- Added masked and audited sensitive-value actions, explicit artifact retention/pinning, selective verified encrypted transfer, locked atomic state, a dedicated Runtime tree, and immutable shipped defaults.
