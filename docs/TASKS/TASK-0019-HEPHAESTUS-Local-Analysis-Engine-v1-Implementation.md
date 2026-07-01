# TASK-0019 - HEPHAESTUS Local Analysis Engine v1 Implementation

## Status
Active

## Owner
Codex

## Objective
Implement the first minimal vertical slice of HEPHAESTUS Local Analysis Engine v1 using the TASK-0018 design and ADRs.

## Required Reading
- `PROJECT.md`
- `docs/PROJECT-CHARTER.md`
- `docs/ARCHITECTURE.md`
- `docs/ROADMAP.md`
- `docs/HANDOFF.md`
- `docs/TASKS/QUEUE.md`
- `docs/DESIGN/HEPHAESTUS-Local-Analysis-Engine-v1.md`
- `docs/ADRS/ADR-0001-HEPHAESTUS-Local-Analysis-Boundary.md`
- `docs/ADRS/ADR-0002-Normalized-Output-Schema-Versioning.md`
- `docs/ADRS/ADR-0003-ARGUS-Input-Contract-And-Trust-Model.md`

## Scope
Implement a minimal v1 vertical slice only:

1. Create the local analysis output folder structure under the collected bundle/output root:
   - `Analysis/`
   - `Analysis/normalized/`
   - `Metadata/`
2. Produce schema/version metadata:
   - `Metadata/schema-version.json`
   - `Metadata/bundle-capabilities.json`
3. Produce core analysis artifacts:
   - `Analysis/findings.json`
   - `Analysis/timeline.json`
   - `Analysis/evidence-score.json`
   - `Analysis/normalized/machine-profile.json`
   - `Analysis/report.html`
4. Implement a deterministic rule runner framework with a small starter rule set.
5. Implement evidence-quality handling for missing or unparsable evidence.
6. Implement basic machine-profile normalization from evidence that already exists.
7. Implement starter rules only where current evidence supports them:
   - Evidence missing or parser failed.
   - Storage free-space issue if storage evidence exists.
   - Security product missing or detected if evidence exists.
   - Network default gateway/DNS issue if network evidence exists.
   - Update/pending reboot signal if evidence exists.
8. Generate a self-contained local HTML summary from structured outputs.
9. Ensure analysis failures do not break collection.

## Out of Scope
- Implementing ARGUS.
- Modifying ARGUS.
- Downloading or installing tools.
- Importing, deleting, or modifying untracked `App/NetworkToolkit/LatencyMon/`.
- Broad collector refactoring.
- Full rule catalog implementation.
- Full driver/process/domain/GPO normalization unless a simple existing evidence path already makes it safe within this task.
- Whole-network analysis.
- UI feature changes unless strictly required to call the local analysis step after existing collection.

## Files Expected To Change
Codex must inspect the repository before deciding exact files. Expected implementation areas may include:

- Existing HEPHAESTUS collection/orchestration script files needed to call analysis after collection.
- New local analysis engine files under the appropriate existing HEPHAESTUS/App/Core location.
- Validation/test files if existing patterns support them.
- `docs/TASKS/TASK-0019-HEPHAESTUS-Local-Analysis-Engine-v1-Implementation.md`
- `docs/HANDOFF.md`
- `docs/TASKS/QUEUE.md`
- `docs/HISTORY/CHANGE-LEDGER.md`
- `docs/HISTORY/CHANGELOG.md`

Do not move large code areas or rename architecture roots unless a separate task explicitly authorizes that work.

## Acceptance Criteria
- [ ] Local analysis runs after evidence collection or through an existing safe invocation path.
- [ ] Analysis creates `Analysis/`, `Analysis/normalized/`, and `Metadata/` in the bundle/output root.
- [ ] Required JSON artifacts are generated and parse successfully.
- [ ] JSON artifacts include `schemaVersion`, `generatedAtUtc`, `generator`, and source-bundle metadata where applicable.
- [ ] Starter deterministic rules produce findings when supported by evidence.
- [ ] Missing optional evidence is recorded as missing/skipped and does not fail collection.
- [ ] Parser failures become warnings and do not stop the engine.
- [ ] Local HTML report is generated from structured outputs.
- [ ] Existing smoke test still passes.
- [ ] Button-smoke test still passes or any blocker is documented.
- [ ] No ARGUS implementation is added.
- [ ] Untracked `App/NetworkToolkit/LatencyMon/` remains untouched unless a new task explicitly handles it.
- [ ] Handoff and queue are updated with the next task state.

## Suggested Validation Steps
```powershell
git status --short --branch
powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -SmokeTest
powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -ButtonSmokeTest
Get-ChildItem -Recurse C:\Computer_Toolkit -Filter *.json | Select-Object -First 1 | Out-Null
```

After generating a test bundle, validate expected outputs:

```powershell
$bundle = '<path-to-test-bundle>'
Test-Path "$bundle\Analysis\findings.json"
Test-Path "$bundle\Analysis\timeline.json"
Test-Path "$bundle\Analysis\evidence-score.json"
Test-Path "$bundle\Analysis\normalized\machine-profile.json"
Test-Path "$bundle\Analysis\report.html"
Test-Path "$bundle\Metadata\bundle-capabilities.json"
Test-Path "$bundle\Metadata\schema-version.json"
Get-Content "$bundle\Analysis\findings.json" -Raw | ConvertFrom-Json | Out-Null
Get-Content "$bundle\Analysis\evidence-score.json" -Raw | ConvertFrom-Json | Out-Null
Get-Content "$bundle\Metadata\bundle-capabilities.json" -Raw | ConvertFrom-Json | Out-Null
```

## Rollback Plan
Revert TASK-0019 implementation changes and related documentation updates. Preserve TASK-0018 design and ADRs unless they are proven incorrect by implementation.

## Work Log

### Entry 001
Author: ChatGPT
Date: 2026-07-01
Summary: Created from TASK-0018 design as the focused Codex implementation task.
Files Changed:
- `docs/TASKS/TASK-0019-HEPHAESTUS-Local-Analysis-Engine-v1-Implementation.md`
Validation Performed:
- Design-only task creation; no application validation run by ChatGPT.
Issues:
- Implementation must discover the existing collection output root before wiring analysis execution.
Instructions for Next Owner:
- Codex should implement only the minimal vertical slice described here and should not implement ARGUS or broad collector refactoring.
