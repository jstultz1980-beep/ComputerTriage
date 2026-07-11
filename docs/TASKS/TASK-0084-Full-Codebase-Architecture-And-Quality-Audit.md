# TASK-0084 - Full Codebase Architecture and Quality Audit

## Status
Queued

## Owner
ChatGPT

## Timing
Run after `TASK-0078-Embedded-Tool-Trust-And-EDR-Safe-Distribution` and before `TASK-0079-Release-Packaging-And-Update-Hardening`.

This task is a planned development freeze at a normal task boundary. It must not interrupt an Active Codex task.

## Objective
Perform a very verbose, start-to-finish audit of the entire Computer Triage Toolkit codebase before release packaging begins.

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
Audit the complete runtime and development surface, including:

### Repository and execution inventory
- Every launcher, entry point, module, helper, UI file, collector, analyzer, report generator, deployment script, update script, manifest, configuration file, and embedded-tool integration.
- Purpose, owning subsystem, callers, dependencies, inputs, outputs, side effects, and runtime status for each operational file.

### Startup and shutdown flow
- Launcher flow.
- Module loading order.
- Dot-sourcing and scope behavior.
- Command registration.
- GUI construction and deferred initialization.
- Background work and timers.
- Shutdown, cleanup, singleton, temporary-file, and process handling.

### Redundancy and dead code
- Duplicate functions, constants, registries, commands, rules, layouts, and helper patterns.
- Overlapping implementations with inconsistent behavior.
- Dead, unreachable, obsolete, superseded, abandoned, or compatibility-only code.
- Multiple sources of truth.

### Hidden failures and false success
- Swallowed exceptions.
- Empty `catch` blocks.
- Broad `SilentlyContinue` use that hides meaningful failures.
- Functions that return success after partial or failed work.
- Missing exit-code checks.
- Nonfatal failures not surfaced to technicians.
- Partial-output behavior that appears complete.
- Null, missing-file, malformed-data, and unsupported-platform behavior.

### Code quality and maintainability
- Oversized or multi-responsibility functions.
- Excessive nesting and fragile control flow.
- Global-variable coupling.
- Load-order dependencies.
- Scope leakage.
- Magic values and duplicated configuration.
- Fragile string parsing.
- Inconsistent naming, casing, return values, logging, encoding, path handling, and error handling.
- PowerShell 5.1 compatibility risks.

### Architecture compliance
- UI, orchestration, collection, deterministic analysis, ARGUS analysis, reporting, deployment, and update boundaries.
- HEPHAESTUS/ARGUS responsibility leakage or duplicated reasoning.
- Documented architecture versus actual implementation.
- `Argus` versus `ARGUS` path/casing consistency.

### Security and trust
- Unsafe process launches and argument quoting.
- Credential or sensitive-data exposure.
- Temporary-file and log handling.
- Execution-policy assumptions.
- Network downloads and provenance.
- Embedded-tool trust and allowlisting behavior.
- Client-data boundaries.
- Destructive or privilege-sensitive operations.

### Performance and responsiveness
- Repeated CIM/WMI queries.
- Blocking GUI operations.
- Expensive module loading.
- Repeated disk scans or manifest parsing.
- Process enumeration and polling frequency.
- Timer leaks and duplicate refresh work.
- First-render and tab-switch latency.

### Validation and testing
- Existing parser checks, smoke tests, button-smoke tests, fixture tests, artifact checks, deployment tests, update tests, and hardware-only tests.
- Untested major paths.
- Tests that do not assert meaningful behavior.
- Missing regression coverage.
- Validation that can report success without exercising the target path.

### Deployment and repository hygiene
- Development-only files.
- Runtime-generated files.
- Logs and temporary artifacts.
- Untracked or locally modified tools/configuration.
- Files that should never ship.
- Update/deployment exclusions.
- Manifest drift caused by normal runtime launch.

### Documentation and governance drift
- Architecture, roadmap, task, handoff, ADR, changelog, version, and implementation inconsistencies.
- Completed behavior not documented.
- Documented behavior not implemented.

## Required Deliverables

### 1. Repository inventory
For every operational file, record:
- Path.
- Purpose.
- Owning subsystem.
- Callers and dependencies.
- Inputs and outputs.
- Side effects.
- Runtime/deployment status.

### 2. Startup and execution map
Document the complete execution flow from launch through module loading, GUI initialization, command invocation, triage, HEPHAESTUS, ARGUS, reporting, deployment/update operations, and shutdown.

### 3. Findings register
Each finding must include:
- Unique finding ID.
- Severity: Critical, High, Medium, Low, or Informational.
- Category.
- File path and function/region.
- Evidence.
- Failure mode.
- Reproduction or triggering conditions.
- User/technician impact.
- Recommended correction.
- Change risk.
- Required validation after correction.

### 4. Redundancy report
Document duplicate, overlapping, obsolete, dead, and superseded code plus recommended consolidation boundaries.

### 5. Hidden-failure report
Document swallowed exceptions, false-success conditions, incomplete output, silent fallback, partial execution, and misleading status/reporting behavior.

### 6. Architecture compliance report
Document actual versus intended subsystem boundaries, global-state and load-order risks, responsibility leakage, and recommended module boundaries.

### 7. Testing gap matrix
For every major path, identify existing validation, missing validation, required fixtures, and required future regression tests.

### 8. Remediation backlog
Create focused remediation tasks ordered by:
1. Critical release blockers.
2. High-risk hidden failures.
3. Security and data-integrity issues.
4. Architecture corrections.
5. Safe redundancy cleanup.
6. Maintainability improvements.
7. Deferred post-release debt.

Do not create a single giant cleanup task.

### 9. Release recommendation
Provide:
- Go/no-go recommendation.
- Required fixes before packaging.
- Required fixes before production use.
- Acceptable deferred debt.
- Known limitations that must be documented.

## Out Of Scope
- Fixing findings during the initial audit.
- Broad refactoring.
- Cosmetic UI changes.
- New product features.
- Tool downloads.
- Cleaning unrelated working-tree drift.
- Changing the active task before the audit reaches its scheduled position.

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
- [ ] Release go/no-go recommendation is recorded.
- [ ] No application code is changed during the audit.
- [ ] Handoff and queue remain consistent.

## Validation
- Confirm all operational repository areas were included in the inventory.
- Cross-check findings against actual tracked code.
- Confirm every Critical and High finding has evidence and a remediation task or explicit disposition.
- Confirm no application code changed during the audit.
- Confirm exactly one task remains Active at closeout.

## Completion Rule
TASK-0084 may activate only at its scheduled task boundary. It must never be inserted into the middle of an Active Codex task.