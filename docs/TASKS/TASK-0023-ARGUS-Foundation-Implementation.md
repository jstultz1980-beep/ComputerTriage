# TASK-0023 - ARGUS Foundation Implementation

## Status
Completed

## Owner
Codex

## Objective
Implement the first ARGUS foundation slice using the accepted ARGUS input contract and evidence trust model from ADR-0003.

## Required Reading
- `PROJECT.md`
- `docs/PROJECT-CHARTER.md`
- `docs/ARCHITECTURE.md`
- `docs/ROADMAP.md`
- `docs/HANDOFF.md`
- `docs/TASKS/QUEUE.md`
- `docs/ADRS/ADR-0003-ARGUS-Input-Contract-And-Trust-Model.md`
- `docs/DESIGN/HEPHAESTUS-Local-Analysis-Engine-v1.md`

## Scope
Implement a minimal ARGUS foundation only after this task becomes Active.

Minimum implementation scope:
- Create the approved ARGUS foundation location under the existing architecture.
- Load and validate required HEPHAESTUS contract artifacts:
  - `Metadata/schema-version.json`
  - `Metadata/bundle-capabilities.json`
  - `Analysis/evidence-score.json`
  - `Analysis/findings.json`
  - `Analysis/timeline.json`
  - `Analysis/normalized/machine-profile.json`
- Produce ARGUS input validation output.
- Produce a small analysis summary that prioritizes deterministic HEPHAESTUS findings.
- Clearly label deterministic evidence, normalized evidence, raw evidence, ARGUS inference, and unsupported conclusions.
- Produce a basic ARGUS report artifact.

## Out of Scope
- AI prompt orchestration beyond simple labeled summarization.
- Broad ARGUS reasoning engine.
- Full report styling.
- HEPHAESTUS collector changes.
- HEPHAESTUS Local Analysis Engine changes.
- Whole-network analysis.
- Refactoring unrelated application code.
- Downloading or installing tools.

## Expected Outputs
Recommended first implementation outputs:

```text
ARGUS/input-validation.json
ARGUS/analysis-summary.json
ARGUS/report.md
```

Exact path may use the existing `Core/Argus` architecture path unless a future ADR normalizes casing.

## Acceptance Criteria
- [x] ARGUS loads required HEPHAESTUS contract artifacts.
- [x] ARGUS validates schema and capability metadata before interpretation.
- [x] ARGUS reads evidence-score data and applies evidence-quality caveats.
- [x] ARGUS prioritizes deterministic HEPHAESTUS findings without silently overriding them.
- [x] ARGUS labels inference separately from deterministic evidence.
- [x] Missing or unsupported evidence is called out explicitly.
- [x] Required ARGUS output artifacts are generated and parse where applicable.
- [x] No HEPHAESTUS code is modified.
- [x] No broad GUI or application refactor is performed.
- [x] Handoff and queue are updated when the task is complete.

## Validation Steps
```powershell
git status --short
powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Computer_Toolkit\App\NetworkToolkit.ps1 -CLI -RunCommand "Run Local Analysis"
```

Then validate ARGUS against the generated HEPHAESTUS bundle outputs.

## Rollback Plan
Revert only ARGUS foundation implementation and related task/handoff documentation updates. Do not revert completed TASK-0019 HEPHAESTUS Local Analysis Engine v1 implementation.

## Work Log

### Entry 001
Author: ChatGPT
Date: 2026-07-01
Summary: Created by TASK-0020 as a queued implementation task. This task must not begin until active and until required audit gates are clear.
Files Changed:
- `docs/TASKS/TASK-0023-ARGUS-Foundation-Implementation.md`
Validation Performed:
- Design/task creation only.
Issues:
- Documentation counter reached audit threshold during TASK-0020, so this implementation task remains queued behind the required audit gate.
Instructions for Next Owner:
- Codex should not implement this until it is the only active task and the audit requirement is cleared.

### Entry 002
Author: Codex
Date: 2026-07-02
Summary: Implemented the minimal ARGUS foundation slice under `Core\Argus` with a console command bridge.
Files Changed:
- `Core/Argus/ArgusFoundation.ps1`
- `App/NetworkToolkit/Core/ArgusFoundationCommand.ps1`
- `docs/TASKS/TASK-0023-ARGUS-Foundation-Implementation.md`
Validation Performed:
- Loaded toolkit console modules with `-CLI -NoConsole`.
- Confirmed `Invoke-ARGUSFoundationAnalysis` is available.
- Ran ARGUS against `C:\Computer_Toolkit\App\NetworkToolkit\Exports\AI-Bundles`.
- Confirmed generated outputs:
  - `ARGUS/input-validation.json`
  - `ARGUS/analysis-summary.json`
  - `ARGUS/report.md`
- Parsed generated JSON outputs successfully.
- Confirmed input validation status was `limited`, reflecting partial/planned bundle capabilities rather than a fatal contract failure.
- Confirmed required artifact count was `6`, prioritized deterministic findings count was `5`, unsupported capability count was `4`, and inference was labeled `argusInference`.
- Parser validation passed for both ARGUS PowerShell files.
- Console command registry contains `Run ARGUS Foundation`.
- CLI smoke passed with `-RunCommand "Run ARGUS Foundation"`.
Issues:
- Current HEPHAESTUS sample bundle has partial evidence, so ARGUS correctly emits limited-mode caveats.
- Local working tree still has unrelated runtime/stale-file noise documented in handoff notes.
Instructions for Next Owner:
- TASK-0028 is the next active task.

## Completion Notes
TASK-0023 is complete. ARGUS Foundation now validates HEPHAESTUS contract artifacts, prioritizes deterministic findings without overriding them, labels inference separately, and writes the first ARGUS output set.
