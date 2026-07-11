# TASK-0084 Remediation Backlog

Status: Proposed by audit
Owner of implementation tasks: Codex
Audit owner: ChatGPT

## Remediation Policy

No new feature work should begin until the Critical finding and the High findings in Waves 1 and 2 are resolved or explicitly deferred by the Project Custodian with written justification.

The audit does not recommend a broad rewrite. Work is divided into focused tasks with explicit validation and rollback boundaries.

## Wave 1 - Evidence Integrity and False-Success Elimination

### TASK-0086 - Offline Evidence Isolation and Bundle Identity

Severity addressed: Critical / High

Findings:
- HF-006 cross-machine evidence contamination.
- HF-009 invalid/default bundle selection.
- HF-010 generated-output self-contamination.
- HF-012 ARGUS wrong default export selection.
- DEP-014 missing immutable diagnostic run identity.

Objective:
Make bundle analysis deterministic, offline-safe, and bound to an immutable run identity. Analysis must never silently mix host data with bundle evidence.

Required validation:
- Analyze Computer-A fixture on Computer-B host.
- Multiple mixed export directories.
- Invalid and incomplete bundle roots.
- Repeated-run idempotence.
- Run-ID preservation through transfer.

### TASK-0087 - Parser-Backed Evidence Quality and Timeline Semantics

Severity addressed: High

Findings:
- HF-005 invalid JSON/CSV error content.
- HF-007 filename presence treated as parsed evidence.
- HF-008 file metadata presented as event timeline.
- downstream ARGUS confidence amplification.

Objective:
Separate artifact discovery, parse state, semantic validation, completeness, and event time. Produce only valid structured artifacts.

Required validation:
- empty/malformed/truncated/error-text artifacts.
- known event versus file-copy timestamps.
- parser warning and failed parser propagation.

### TASK-0088 - Canonical Operation Result and Failure Propagation

Severity addressed: High

Findings:
- RUN-002 false process success.
- RUN-003 partial startup.
- RUN-006 skipped capability behavior.
- HF-002 through HF-004.
- HF-011 ARGUS failed contract reported Completed.
- PLG-002, PLG-006, PLG-017, PLG-020.
- RED-008 fragmented status vocabulary.

Objective:
Define and adopt a shared result envelope with explicit required-stage outcomes and terminal states:
- Succeeded
- SucceededWithWarnings
- Partial
- Failed
- Blocked
- Canceled

Required validation:
- CLI exit-code tests.
- required/optional module failure tests.
- triage partial/failure fixtures.
- ARGUS failed-contract suppression.
- plugin operation status tests.

### TASK-0089 - Diagnostic Bundle Integrity and Collection Contract

Severity addressed: High

Findings:
- HF-001 stale ZIP self-hash.
- HF-003 collector failure loss.
- HF-004 inaccurate section state.
- incomplete collection manifest semantics.

Objective:
Create a valid diagnostic run manifest and external/canonical integrity record. Persist per-collector outcomes and required/optional artifact states.

Required validation:
- final bundle hash/tamper test.
- command timeout/nonzero exit.
- failed PowerShell collector.
- partial section and missing artifact.

## Wave 2 - ARGUS and Destructive Operation Safety

### TASK-0090 - ARGUS Contract, Citation, and Priority Correctness

Severity addressed: High / Medium

Findings:
- ARG-001 failed contract not fail-closed.
- ARG-002 citation identity not durable.
- ARG-003 fragile domain matching.
- ARG-004 findings conflated with gaps.
- ARG-005 broken recommendation priority ordering.
- ARG-006 unverified upstream confidence.
- ARG-007 linear trust rank conflates concepts.

Objective:
Make ARGUS outputs contract-safe, source-identifiable, correctly ordered, and semantically precise.

Required validation:
- unsupported/malformed/missing contract fixtures.
- stable citation resolution and hash checks.
- exact domain classification fixtures.
- all priority values ordering.
- gap/finding separation.

### TASK-0091 - Print and Remote Change Transaction Safety

Severity addressed: High

Findings:
- PLG-001 clear-all wildcard false success.
- PLG-003 spooler recovery gap.
- PLG-004 misleading ShouldProcess.
- PLG-005 remote-management broad changes without rollback.
- PLG-006 unverified service startup.

Objective:
Capture pre-state, apply changes transactionally where possible, guarantee recovery, return structured per-step outcomes, and provide rollback.

Required validation:
- spooler deletion count and restart verification.
- locked spool files.
- partial firewall/service changes.
- rollback to original service/firewall state.

### TASK-0092 - Transactional Package, Deploy, and Update Integrity

Severity addressed: High

Findings:
- HF-013 through HF-015.
- DEP-001 through DEP-006.
- DEP-011 and DEP-012.

Objective:
Generate a complete managed-file manifest, stage and verify full images, preserve rollback, and reject partial managed-file reconciliation.

Required validation:
- corrupt/missing plugin/module/tool payload.
- locked obsolete file.
- interrupted update/deploy.
- wrong destination identity.
- successful rollback.

### TASK-0093 - External Tool Provenance and Lifecycle Policy

Severity addressed: High / Medium

Findings:
- PLG-007 through PLG-010.
- SEC-002, SEC-004, SEC-008, SEC-009.
- DEP-012.

Objective:
Define tool source, version, hash, signature, publisher, license, expiration/update cadence, privilege, EDR guidance, and package inclusion policy.

Required validation:
- hash/signature mismatch.
- missing/expired tool.
- locally added tool classification.
- EULA acceptance workflow.

### TASK-0094 - Sensitive Artifact Handling and Runtime State Safety

Severity addressed: High / Medium

Findings:
- PLG-011 through PLG-015.
- SEC-005 through SEC-007.
- DEP-007 through DEP-010 and DEP-013.

Objective:
Mask sensitive values by default, classify artifacts, implement explicit retention/pinning, verify transfers, and make state writes atomic.

Required validation:
- software-key masking/reveal/export.
- sensitive report retention.
- encrypted/selective transfer.
- atomic write interruption/concurrency.
- runtime/default manifest separation.

## Wave 3 - Architecture Stabilization and Consolidation

### TASK-0095 - Canonical Analysis and Tool Metadata Architecture

Severity addressed: High / Medium

Findings:
- RED-001 duplicate deterministic functions.
- RED-002 parallel analysis stacks.
- RED-006 multiple tool catalogs.
- RED-012 multiple manifest concepts.
- PLG-016 Quick Diagnosis overlap.

Objective:
Remove duplicate global definitions, establish canonical service contracts, and normalize tool/run/artifact descriptors without removing working features prematurely.

Validation:
- duplicate symbol detection.
- Quick Diagnosis versus shared analysis comparison fixtures.
- tool catalog/search/tab/source consistency.

### TASK-0096 - GUI Background Operation Controller Extraction

Severity addressed: High / Medium

Findings:
- PLG-018 and PLG-019.
- PERF-001 and PERF-002.

Objective:
Extract one reusable process/job/timer lifecycle controller and migrate high-risk Analyze/Triage workflows first.

Validation:
- repeated start/cancel/close.
- timeout/failure/success result states.
- no leaked processes/jobs/timers.
- smoke/button-smoke regression.

### TASK-0097 - Architecture, Terminology, and Governance Consolidation

Severity addressed: High / Medium

Findings:
- GOV-001 through GOV-006.
- GOV-002 architecture baseline deficiency.
- stale HEPHAESTUS terminology.

Objective:
Adopt descriptive subsystem names except ARGUS, expand architecture documentation, simplify roadmap/queue roles, and consolidate repeated governance text without weakening controls.

Validation:
- repository terminology inventory.
- Resume Work and Address Errors simulations.
- handoff/queue/task consistency checks.

### TASK-0098 - Shared Reporting and Run Index Contracts

Severity addressed: Medium / High

Findings:
- RED-003, RED-004, RED-011.
- inconsistent report metadata and latest-state pointers.

Objective:
Create shared report metadata/escaping helpers and an immutable run index linking artifacts by run ID.

Validation:
- report snapshot/escaping tests.
- stale/deleted artifact behavior.
- multiple-run selection.

## Wave 4 - Regression and Performance Gates

### TASK-0099 - Repository-Wide Validation Foundation

Severity addressed: High

Findings:
- testing matrix gaps.
- DEP-015.

Objective:
Add Windows PowerShell 5.1 parser validation, required module/plugin load completeness, negative-path fixtures, package manifest checks, and core regression tests.

This task may begin in parallel only after the contracts it tests are stable enough to avoid encoding known-bad behavior.

### TASK-0100 - Performance Instrumentation and Run-Scoped Observation Cache

Severity addressed: High / Medium

Findings:
- PERF-001 through PERF-012.

Objective:
Add structured timing and provider-health telemetry, define time budgets, reduce repeated CIM/event/tool discovery, and establish cold/warm baselines.

Validation:
- startup and first-render thresholds.
- Quick Diagnosis time budget.
- repeated workflow resource-leak checks.
- provider failure cache behavior.

## Existing Finish-Line Tasks

The following remain queued but should not resume unchanged until remediation sequencing is accepted:

- TASK-0077 First-Render Tab Performance Hardening: should be reconciled with TASK-0096 and TASK-0100.
- TASK-0078 Embedded Tool Trust and EDR-Safe Distribution: should be reconciled with TASK-0093.
- TASK-0079 Release Packaging and Update Hardening: should be reconciled with TASK-0092.
- TASK-0080 Release Candidate Validation and Documentation: remains last, after Critical/High remediation.

## Mandatory Order

Minimum unblock order:

1. TASK-0086
2. TASK-0087
3. TASK-0088
4. TASK-0089
5. TASK-0090
6. TASK-0091
7. TASK-0092
8. TASK-0093
9. TASK-0094
10. TASK-0099 core gates

Wave 3 consolidation may then proceed in risk-informed order, followed by performance work and release-path tasks.
