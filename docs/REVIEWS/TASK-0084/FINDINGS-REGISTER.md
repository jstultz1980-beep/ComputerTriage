# TASK-0084 Findings Register

Status: In Progress
Auditor: ChatGPT

Severity definitions:
- Critical: immediate data-loss, security, or fundamental product-integrity risk.
- High: major hidden failure, false success, architecture defect, or release-blocking reliability issue.
- Medium: material maintainability, drift, performance, or validation issue.
- Low: localized cleanup or governance improvement.
- Informational: observation requiring no immediate remediation.

## Summary

| ID | Severity | Category | Status | Short Description |
|---|---|---|---|---|
| GOV-001 | Medium | Documentation | Open | Product terminology is internally inconsistent. |
| GOV-002 | High | Architecture | Open | Architecture document is materially under-specified. |
| GOV-003 | Medium | Documentation | Open | Roadmap mixes current plan and historical activity. |
| GOV-004 | Medium | Task System | Open | Queue duplicated excessive historical state. |
| GOV-005 | Medium | Governance | Open | Governance rules are distributed and repeatedly restated. |
| GOV-006 | Low | Governance | Open | Counter model may over-count routine documentation bookkeeping. |
| RUN-001 | High | Privilege/Security | Open | Normal launcher requests elevation for every GUI start. |
| RUN-002 | High | Error Handling | Open | CLI command failures can be displayed but returned as successful process completion. |
| RUN-003 | High | Startup Integrity | Open | Module/plugin import failures are collected but startup continues in a partially loaded state. |
| RUN-004 | Medium | Architecture | Open | Core runtime depends on broad global mutable state and dot-source load order. |
| RUN-005 | Medium | Deployment/Hygiene | Open | Normal startup creates and mutates runtime data inside the application tree. |
| RUN-006 | Medium | Validation | Open | Optional cleanup and command availability checks can silently mask incomplete module loading. |

---

## GOV-001 - Product terminology is internally inconsistent

Severity: Medium
Category: Documentation / Architecture
Location: `PROJECT.md`, `docs/PROJECT-CHARTER.md`, `docs/ROADMAP.md`, task/design history

Evidence:
- `PROJECT.md` now uses `Evidence Collection and Deterministic Analysis` plus ARGUS.
- `docs/PROJECT-CHARTER.md` still names HEPHAESTUS as the evidence collection engine.
- `docs/ROADMAP.md` retains HEPHAESTUS phase names and descriptions.

Failure mode:
Contributors, prompts, logs, and design documents use competing names for the same subsystem.

Trigger:
Any architecture discussion, new task, code-path naming decision, or troubleshooting involving the development machine also named HEPHAESTUS.

Impact:
Ambiguous subsystem ownership and continued cross-project codename leakage.

Recommendation:
Create a focused terminology migration after the read-only audit. Keep ARGUS; replace other codenames with canonical descriptive subsystem names and maintain a documented legacy mapping.

Change risk: Medium
Required validation: repository-wide reference inventory; output/path/API compatibility review.

## GOV-002 - Architecture document is materially under-specified

Severity: High
Category: Architecture
Location: `docs/ARCHITECTURE.md`

Evidence:
The document primarily lists top-level folders and describes ARGUS in a few lines. It does not define the implemented collection, deterministic analysis, normalization, grouping, recommendations, reports, GUI workflow, deployment/update boundaries, contracts, or failure behavior.

Failure mode:
Architecture must be reconstructed from task history and implementation rather than one intended-state baseline.

Trigger:
Any implementation, review, refactor, debugging session, or contributor onboarding.

Impact:
Higher risk of duplicated responsibilities, scope conflict, and inconsistent implementation decisions.

Recommendation:
Create a focused architecture-baseline task after the audit.

Change risk: Low for documentation; Medium for later alignment work.
Required validation: cross-check every documented component against tracked code and generated artifacts.

## GOV-003 - Roadmap mixes current planning and historical activity

Severity: Medium
Category: Documentation
Location: `docs/ROADMAP.md`

Evidence:
The roadmap contains extensive historical task chronology, stale `Planned tasks` language for completed work, and a finish-line list that does not reflect the user-selected early audit boundary.

Failure mode:
Current state becomes obscured and can conflict with queue/handoff.

Recommendation:
Reduce the roadmap to phases, objectives, dependencies, state, and upcoming milestones. Leave detailed chronology to changelog/task history.

Change risk: Low
Required validation: queue/task/roadmap consistency check.

## GOV-004 - Queue duplicated excessive historical state

Severity: Medium
Category: Task System
Location: `docs/TASKS/QUEUE.md`

Evidence:
Before TASK-0084 activation, the queue repeated a large historical task table already represented by individual task files and history.

Failure mode:
Stale trailing text or historical rows conflict with Active table and handoff.

Impact:
Codex has already blocked on stale queue reconciliation text during prior transitions.

Recommendation:
Keep queue operational: one Active task, ordered queued work, recent completions, and concise decisions.

Change risk: Low
Required validation: automated one-active-task and file-existence checks.

## GOV-005 - Governance rules are distributed and repeatedly restated

Severity: Medium
Category: Governance
Location: `PROJECT.md`, `AGENTS.md`, CLI operating instructions, guardrails, handoff, queue, active task, error handoff

Evidence:
The same startup, autonomy, non-interruption, and precedence concepts appear in several files.

Failure mode:
One stale or missing copy blocks work despite another correct source.

Impact:
The project has already encountered a missing CLI instruction file and contradictory handoff scope.

Recommendation:
Consolidate principles and use short references rather than repeating full rules.

Change risk: Medium
Required validation: simulated `Resume Work`, `Address Errors`, audit-gate, and blocked-task scenarios.

## GOV-006 - Counter model may over-count routine bookkeeping

Severity: Low
Category: Governance
Location: audit counter policy and change ledger

Evidence:
Documentation repeatedly reaches its threshold through mandatory task closeout edits.

Failure mode:
Implementation is paused for consistency audits that may mostly review required bookkeeping.

Recommendation:
Evaluate whether routine task-state updates belong only to Task System unless they materially change product/governance documentation.

Change risk: Medium
Required validation: replay recent task history using revised counting definitions.

## RUN-001 - Normal launcher requests elevation for every GUI start

Severity: High
Category: Security / Privilege Boundary
Location: `NetworkToolkit.vbs`, lines 17-21

Evidence:
The VBS launcher always calls `ShellExecute` with the `runas` verb, even when no specific action has been identified as requiring elevation.

Failure mode:
The entire application runs elevated by default. Any UI, plugin, report viewer, external tool launcher, or compromised/incorrect script loaded into the process inherits administrative rights.

Trigger:
Launching the toolkit through the normal VBS entry point.

Impact:
Expanded privilege and attack surface, unnecessary UAC prompts, and weaker separation between read-only diagnostics and privileged repair operations.

Recommendation:
Introduce least-privilege startup. Elevate only commands explicitly marked `RequiresAdmin`; validate that GUI workflows can request elevation at the action boundary.

Change risk: High because some existing functions may implicitly depend on elevation.
Required validation: non-admin smoke/button-smoke, elevated command tests, collector permissions matrix, report-only workflow tests.

## RUN-002 - CLI command failures can return false success

Severity: High
Category: Error Handling / Process Contract
Location: `App/NetworkToolkit/NetworkToolkit-Core.ps1`, command execution and top-level catch blocks; `App/NetworkToolkit.ps1`, CLI exit propagation

Evidence:
- Command invocation exceptions are caught, printed, and followed by `return` without setting a nonzero exit code.
- The top-level console catch also prints and continues to shutdown logging.
- `App/NetworkToolkit.ps1` exits using `$LASTEXITCODE`, which is not reliably set by failed PowerShell function invocation.

Failure mode:
Automation or validation can observe process exit code 0 after a command failed.

Trigger:
Any registered command that throws, is missing, or fails within PowerShell without launching a native process that sets `$LASTEXITCODE`.

Impact:
False-success validation, unreliable scripting integration, and hidden failures in chained analysis workflows.

Recommendation:
Define an explicit process-result contract. Set deterministic exit codes for command-not-found, cancellation, validation failure, partial success, and unhandled failure. Avoid relying on ambient `$LASTEXITCODE` for PowerShell functions.

Change risk: Medium
Required validation: positive, missing-command, thrown-exception, cancellation, partial-output, and native-child exit-code tests.

## RUN-003 - Startup continues after module/plugin import failures

Severity: High
Category: Startup Integrity / Hidden Failure
Location: `App/NetworkToolkit/NetworkToolkit-Core.ps1`, module and plugin loaders

Evidence:
- Module and plugin errors are added to `$Global:NTKImportFailures` and startup continues.
- Only the console entry function is treated as mandatory.
- Missing optional commands can therefore surface later as button failures, incomplete workflows, or missing results.

Failure mode:
The toolkit can present a usable-looking interface while important subsystems failed to load.

Trigger:
Parser error, missing dependency, incompatible PowerShell code, missing plugin script, or runtime exception during dot-source.

Impact:
Partial functionality and delayed failures that are harder to associate with startup cause.

Recommendation:
Classify modules as required or optional. Fail closed for required modules. Surface a persistent degraded-mode state for optional failures and disable affected controls with explicit reason.

Change risk: Medium
Required validation: synthetic required-module failure, optional-plugin failure, GUI degraded-state tests, command registry completeness assertions.

## RUN-004 - Core runtime depends on global mutable state and dot-source order

Severity: Medium
Category: Architecture / Maintainability
Location: `ToolkitPaths.ps1`, `CommandRegistry.ps1`, `NetworkToolkit-Core.ps1`

Evidence:
- Paths, files, registry, import failures, plugin-loading state, and mutex state are stored globally.
- Modules are dot-sourced in filename order.
- Command source detection depends on a temporary global variable.

Failure mode:
A module can unintentionally overwrite another module’s variables/functions, and behavior can depend on load order or prior process state.

Trigger:
New module/function names, refactoring, plugin load failures, direct script invocation, or tests sharing a process.

Impact:
Fragile extensibility, difficult isolation tests, and hidden coupling.

Recommendation:
Define explicit module boundaries and context objects. Migrate high-risk globals incrementally rather than performing a broad rewrite.

Change risk: High
Required validation: import-order tests, duplicate symbol detection, isolated module tests, direct-entry tests.

## RUN-005 - Normal startup mutates runtime data inside the application tree

Severity: Medium
Category: Deployment / Repository Hygiene
Location: `ToolkitPaths.ps1` and `NetworkToolkit-Core.ps1`

Evidence:
Logs, exports, data, temp outputs, custom folders, and manifests are resolved under the application/deployment tree and created or written during startup.

Failure mode:
A read-only deployment, protected installation path, copied toolkit, or source checkout accumulates runtime state and modified tracked manifests.

Trigger:
Normal startup, report generation, tool output, or manifest provenance migration.

Impact:
Deployment drift, update conflicts, source-tree noise, permission failures, and accidental client-data inclusion.

Recommendation:
Document and enforce a runtime-data root separate from immutable application files, or clearly classify portable writable directories with update/deployment exclusions.

Change risk: High because portability and client-data transfer depend on current paths.
Required validation: read-only app-root test, portable USB test, update preservation test, client-data transfer test.

## RUN-006 - Conditional cleanup and command checks can mask incomplete loading

Severity: Medium
Category: Validation / Startup
Location: `App/NetworkToolkit/NetworkToolkit-Core.ps1`

Evidence:
Cleanup helpers are called only when `Get-Command` finds them; missing helpers are silently skipped. The same pattern is used broadly for optional runtime capabilities.

Failure mode:
A failed module import can remove retention/cleanup behavior without creating an explicit operational warning beyond the initial console message.

Trigger:
Utility module load failure or renamed/missing helper.

Impact:
Unbounded logs/temp outputs or inconsistent behavior between installations.

Recommendation:
Add a startup capability manifest and required-command assertions. Tie skipped cleanup to visible degraded-state diagnostics.

Change risk: Low to Medium
Required validation: missing-helper fixture, quota/retention behavior tests, startup capability report assertion.
