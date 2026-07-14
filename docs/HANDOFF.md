# Current Handoff

## Handoff ID
HANDOFF-0125

## Current Task
TASK-0114-Performance-QA-Instrumentation-And-Settings-Dashboard

## Current Owner
Codex

## Next Owner
ChatGPT (Project Custodian) after TASK-0114 completes focused and canonical validation and provides objective real-world performance QA evidence.

## Objective
Add unbiased, persistent performance instrumentation and automated QA reporting for real-world testing, with the Performance Dashboard accessible only from the Settings page.

## Source Of Truth
The repository is authoritative. Exactly one task may be Active, and handoff, queue, and Active task file must agree.

## Current Project State
- Version 1.0 is published as `v1.0.0` from accepted commit `38de0b626fe3cadc6848a12b9e40fadfc7006151`.
- Release publication and Project Custodian closeout are complete.
- The user authorized a focused performance QA instrumentation cycle before formal real-world QA review.
- TASK-0100 already provides performance telemetry and run-scoped observations.
- TASK-0112 already provides cold-tab warm-up and per-stage tab timing.
- TASK-0114 must extend those contracts rather than create a competing framework.
- TASK-0114 is the sole Active Codex task.
- The Performance Dashboard must be accessible only from Settings and must not appear in primary navigation.
- The published Version 1.0 tag and release artifacts must remain unchanged.
- Unrelated features, helper frameworks, native replacements, and broad UI redesign remain deferred.

## Active Task Scope
`TASK-0114-Performance-QA-Instrumentation-And-Settings-Dashboard`

Codex must add launch-through-`ReadyForUser` timing, normalized cold/warm tab and operation timing, toolkit-controlled external-tool timing, bounded resource telemetry, automated QA analysis, export, and a Settings-only Performance Dashboard. Timing must use a monotonic duration source; telemetry must be bounded, append-safe, privacy-conscious, and low overhead. Codex must preserve PowerShell 5.1 behavior, current lifecycle/cancellation semantics, the published release, and unrelated drift.

## Audit Counters

| Subsystem | Changes Since Last Audit | Audit Required |
|---|---:|---|
| Repository Governance | 15 / 25 | No |
| Architecture | 19 / 25 | No |
| Documentation | 24 / 25 | No |
| Task System | 9 / 25 | No |
| Evidence Collection and Deterministic Analysis | 10 / 25 | No |
| ARGUS | 10 / 25 | No |
| Reporting | 5 / 25 | No |
| UI | 6 / 25 | No |
| Plugin Framework | 6 / 25 | No |
| Build System | 8 / 25 | No |
| Validation/Test Framework | 16 / 25 | No |
| Roadmap/Backlog | 12 / 25 | No |

## Known Working-Tree Drift
Do not stage or clean unless a focused task explicitly owns it:
- Modified: `App/manifests/custom-tools.json`
- Modified locally: `docs/ADRS/ADR-0003-ARGUS-Input-Contract-And-Trust-Model.md`
- Untracked: `App/NetworkToolkit/LatencyMon/`
- Untracked: `App/NetworkToolkit/Logs/`
- Untracked: `Custodian-Audit-20260711-000156.md`
- Untracked: `Project-Custodian-Bridge.ps1`
- Untracked: `Export-ProjectFactoryGovernancePackage.ps1`
- Untracked: `Project-Factory-Governance-Handoff.zip`
- Untracked: `Project-Factory-Lessons-Learned-Handoff.txt`
- Untracked: `Set-CodexPermissions.ps1`

## Blockers
None.

## Decision Reference
- `docs/TASKS/TASK-0114-Performance-QA-Instrumentation-And-Settings-Dashboard.md`
- `docs/TASKS/TASK-0100-Performance-Instrumentation-And-Run-Scoped-Observation-Cache.md`
- `docs/TASKS/TASK-0112-Cold-Tab-Initialization-Performance-Remediation.md`
- `docs/GOVERNANCE/HANDOFF-STATE-AND-FINGERPRINT-PROTOCOL.md`

## Next Bot Prompt
```text
Resume Work
```
