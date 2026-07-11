# TASK-0084 - Full Codebase Architecture and Quality Audit

## Status
Active

## Owner
ChatGPT

## Timing
Activated at the task boundary immediately after `TASK-0085-Documentation-Counter-Audit` completed.

The user explicitly selected the planned full-codebase audit before TASK-0077 and TASK-0078. This is a normal task-boundary change and does not interrupt an Active Codex implementation task.

## Objective
Perform a very verbose, start-to-finish audit of the entire Computer Triage Toolkit codebase before further feature or release-hardening work.

The audit must identify redundancies, hidden failures, false-success conditions, unsafe assumptions, sloppy code, architectural drift, validation gaps, deployment drift, and technical debt.

## Audit Mode
The first pass is read-only.

Do not refactor, clean, rename, reorganize, or repair application code during the audit. Record findings first, then create focused remediation tasks.

Implementation remains frozen while this audit is Active, except for documentation required to record audit findings and task state.

## Required Reading
- `AGENTS.md`
- `PROJECT.md`
- `docs/PROJECT-CHARTER.md`
- `docs/ARCHITECTURE.md`
- `docs/ROADMAP.md`
- `docs/HANDOFF.md`
- `docs/TASKS/QUEUE.md`
- `docs/PROJECT-FINISH-PLAN.md`
- `docs/HISTORY/CHANGE-LEDGER.md`
- `docs/HISTORY/CHANGELOG.md`
- All accepted ADRs
- All active design documents
- Deployment/update policy and manifest files
- Every operational script and module in the repository

## Scope
Audit the complete runtime and development surface.

### Repository and execution inventory
Record every launcher, entry point, module, helper, UI file, collector, analyzer, report generator, deployment script, update script, manifest, configuration file, and embedded-tool integration, including purpose, owner, callers, dependencies, inputs, outputs, side effects, and deployment status.

### Startup and shutdown flow
Trace launcher flow, module load order, dot-sourcing and scope behavior, command registration, GUI construction, deferred initialization, background work, timers, shutdown, cleanup, singleton handling, temporary files, and child processes.

### Redundancy and dead code
Identify duplicate functions, constants, registries, commands, rules, layouts, helper patterns, overlapping implementations, dead code, compatibility-only code, superseded code, and multiple sources of truth.

### Hidden failures and false success
Identify swallowed exceptions, empty catch blocks, broad `SilentlyContinue`, success after partial failure, missing exit-code checks, incomplete outputs that appear complete, null/missing/malformed input behavior, and unsupported-platform behavior.

### Code quality and maintainability
Review function size, responsibility boundaries, nesting, global state, load-order dependencies, scope leakage, magic values, duplicated configuration, fragile parsing, naming/casing, return values, logging, encoding, path handling, error handling, and PowerShell 5.1 compatibility.

### Architecture compliance
Review UI, orchestration, collection, deterministic analysis, ARGUS, reporting, deployment, and update boundaries; documented architecture versus implementation; and `Argus` versus `ARGUS` path/casing.

### Security and trust
Review process launch and argument quoting, credentials and sensitive data, temp/log handling, execution-policy assumptions, network downloads, provenance, embedded-tool trust, client-data boundaries, and destructive/privileged operations.

### Performance and responsiveness
Review repeated CIM/WMI queries, blocking GUI operations, expensive loading, repeated disk scans/manifest parsing, process polling, timer leaks, duplicate refresh work, and first-render/tab-switch latency.

### Validation and testing
Review parser checks, smoke tests, button-smoke tests, fixtures, artifact checks, deployment tests, update tests, hardware-only tests, untested major paths, false-positive tests, and missing regression coverage.

### Deployment and repository hygiene
Review development-only files, runtime-generated files, logs, temporary artifacts, untracked/local tools and configuration, shipping exclusions, update/deployment policy, and runtime manifest mutation.

### Documentation and governance drift
Review architecture, roadmap, tasks, handoff, ADRs, changelog, version metadata, and implementation consistency.

## Required Deliverables
1. Repository inventory.
2. Startup and execution map.
3. Severity-ranked findings register.
4. Redundancy report.
5. Hidden-failure report.
6. Architecture compliance report.
7. Testing gap matrix.
8. Focused remediation backlog.
9. Release/readiness recommendation appropriate to the project’s current stage.

Each finding must include a unique ID, severity, category, path/function, evidence, failure mode, trigger, impact, recommendation, change risk, and required validation.

## Out Of Scope
- Fixing findings during the initial audit.
- Broad refactoring.
- Cosmetic UI work.
- New product features.
- Tool downloads.
- Cleaning unrelated working-tree drift.

## Acceptance Criteria
- [ ] Entire operational codebase is inventoried.
- [ ] Startup-to-shutdown flow is documented.
- [ ] Findings are evidence-based and severity-ranked.
- [ ] Redundancies and dead code are identified.
- [ ] Hidden failures and false-success conditions are identified.
- [ ] Architecture compliance is evaluated.
- [ ] Security, performance, deployment, and validation risks are covered.
- [ ] Testing gap matrix is complete.
- [ ] Focused remediation tasks are created and ordered.
- [ ] Readiness recommendation is recorded.
- [ ] No application code is changed during the audit.
- [ ] Handoff and queue remain consistent.

## Validation
- Confirm all operational repository areas were included in the inventory.
- Cross-check findings against actual tracked code.
- Confirm every Critical and High finding has evidence and a remediation task or explicit disposition.
- Confirm no application code changed during the audit.
- Confirm exactly one task remains Active at closeout.

## Audit Work Log

### Entry 001
Author: ChatGPT
Date: 2026-07-10
Summary: Activated TASK-0084 after completing the mandatory TASK-0085 Documentation counter audit. Development freeze is in effect and the first pass is read-only.
Files Changed:
- `docs/TASKS/TASK-0085-Documentation-Counter-Audit.md`
- `docs/TASKS/TASK-0084-Full-Codebase-Architecture-And-Quality-Audit.md`
- `docs/TASKS/QUEUE.md`
- `docs/HANDOFF.md`
- Audit report files under `docs/REVIEWS/TASK-0084/`
Validation Performed:
- Verified TASK-0085 source-of-truth consistency.
- Verified recent TASK-0073 through TASK-0076 completion records.
- Verified documented working-tree drift remains excluded.
Issues:
- Initial governance review identified stale codename and roadmap-detail drift to be recorded as audit findings, not fixed during the read-only pass.
Instructions for Next Owner:
- ChatGPT continues TASK-0084 until the audit deliverables and remediation queue are complete.

## Completion Rule
TASK-0084 remains Active until all required audit deliverables are complete and the remediation sequence is recorded. Codex remains in Engineering Support mode during the audit.
