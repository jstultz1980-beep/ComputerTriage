# Current Handoff

## Handoff ID
HANDOFF-0128

## Current Task
TASK-0118-Startup-Warmup-And-Heavy-Tab-Deferral

## Current Owner
Codex

## Next Owner
ChatGPT (Project Custodian) after TASK-0118 completes measured validation and returns before/after launch and heavy-tab evidence.

## Objective
Reduce the measured 4.5-4.9 second shell-to-usable-window time by replacing eager 27-tab launch warm-up with bounded idle/on-demand initialization and making the heaviest tabs truly deferred.

## Source Of Truth
The repository is authoritative. Exactly one task may be Active, and handoff, queue, and Active task file must agree.

## Current Project State
- Version 1.0 remains published as `v1.0.0` from accepted commit `38de0b626fe3cadc6848a12b9e40fadfc7006151`.
- TASK-0114 performance QA instrumentation and the Settings-only dashboard are complete.
- TASK-0116 accepted the Documentation audit and reset only Documentation to `0 / 25`.
- TASK-0117 corrected default-launch clipping and completed validation.
- The live performance audit measured shell-to-usable-window time at approximately 4.5-4.9 seconds.
- Launch currently schedules 27 tabs for deferred warm-up, which is the primary measured bottleneck.
- Print, Analyze, Directory, and Windows Update have the highest observed first-render costs.
- TASK-0118 is the sole Active Codex task.
- The separate deferred-startup `Write-GUILog` failure remains outside TASK-0118 and requires independent sequencing.
- The Performance Dashboard remains accessible only from Settings.
- The published Version 1.0 tag and release artifacts must remain unchanged.

## Active Task Scope
`TASK-0118-Startup-Warmup-And-Heavy-Tab-Deferral`

Codex must capture the baseline, replace eager 27-tab launch warm-up with a bounded cost-aware idle/on-demand policy, defer expensive embedded-script/live-data work for the heaviest tabs, reduce avoidable startup UI churn, and validate measurable improvement using the existing TASK-0100/TASK-0112/TASK-0114 telemetry. It must preserve user-selection priority, one-time initialization, failure isolation, PowerShell 5.1 behavior, lifecycle semantics, unrelated drift, and the published release.

## Audit Counters

| Subsystem | Changes Since Last Audit | Audit Required |
|---|---:|---|
| Repository Governance | 17 / 25 | No |
| Architecture | 20 / 25 | No |
| Documentation | 2 / 25 | No |
| Task System | 13 / 25 | No |
| Evidence Collection and Deterministic Analysis | 11 / 25 | No |
| ARGUS | 10 / 25 | No |
| Reporting | 6 / 25 | No |
| UI | 9 / 25 | No |
| Plugin Framework | 6 / 25 | No |
| Build System | 10 / 25 | No |
| Validation/Test Framework | 18 / 25 | No |
| Roadmap/Backlog | 16 / 25 | No |

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
- `docs/TASKS/TASK-0118-Startup-Warmup-And-Heavy-Tab-Deferral.md`
- `docs/REVIEWS/TASK-0117/PERFORMANCE-AUDIT-FINDINGS.md`
- `docs/TASKS/TASK-0117-Responsive-Initial-Layout-And-DPI-Remediation.md`
- `docs/TASKS/TASK-0114-Performance-QA-Instrumentation-And-Settings-Dashboard.md`
- `docs/TASKS/TASK-0112-Cold-Tab-Initialization-Performance-Remediation.md`
- `docs/GOVERNANCE/HANDOFF-STATE-AND-FINGERPRINT-PROTOCOL.md`

## Next Bot Prompt
```text
Resume Work
```
