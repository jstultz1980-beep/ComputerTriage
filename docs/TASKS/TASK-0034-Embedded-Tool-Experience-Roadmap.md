# TASK-0034 - Embedded Tool Experience Roadmap

## Status
Queued

## Owner
ChatGPT

## Objective
Create a prioritized roadmap for turning more launch-only tools into embedded tab experiences where that improves technician workflow.

## Scope
- Inventory launch-only tools that would benefit from embedded UI.
- Identify tools that should get their own tab versus live inside an existing tab.
- Rank candidates by troubleshooting value, implementation risk, and expected technician benefit.
- Prefer embedded tab experiences for tools where the technician needs to read, filter, compare, or act on structured output.
- Keep simple external app launchers as launchers when embedding does not reduce effort or uncertainty.
- Define small Codex implementation tasks for the highest-value candidates.

## Candidate Areas
- Print queue maintenance.
- Directory/domain diagnostics.
- Network discovery and service tests.
- Crash/minidump review.
- Windows Update diagnostics.
- Remote/PsExec helpers.
- Choco/package management refinements.

## Out of Scope
- Application code changes.
- Tool downloads or removals.
- ARGUS implementation.
- Untracked `App/NetworkToolkit/LatencyMon/`.

## Acceptance Criteria
- [ ] Embedded-tool candidates are prioritized.
- [ ] Each recommendation states why embedded UI is better than a launcher.
- [ ] Each recommendation states whether the tool belongs on an existing tab or should get a dedicated tab.
- [ ] Each accepted candidate has a small follow-on Codex task.
- [ ] Tasks avoid overloading any single tab.
