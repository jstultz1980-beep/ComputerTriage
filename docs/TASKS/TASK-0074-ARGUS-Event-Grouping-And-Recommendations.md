# TASK-0074 - ARGUS Event Grouping And Recommendations

## Status
Complete

## Owner
Codex

## Purpose
Turn normalized ARGUS facts into coherent diagnostic groups and technician recommendations.

## Scope
- Group related symptoms and events.
- Produce root-cause candidates with confidence.
- Generate technician-facing recommended next actions.
- Cite deterministic findings and normalized evidence for each recommendation.
- Consume `ARGUS/normalized-analysis.json` from TASK-0073.
- Produce `ARGUS/diagnostic-groups.json` and `ARGUS/recommendations.json`.

## Out Of Scope
- UI integration.
- Final report styling.
- Whole-network or multi-machine reasoning.

## Acceptance Criteria
- [x] ARGUS emits grouped diagnostic themes.
- [x] Recommendations include confidence and citations.
- [x] Recommendations identify blocked or limited conclusions caused by missing evidence.
- [x] Unsupported conclusions are labeled instead of implied.
- [x] Validation covers at least one normal, limited, and problem-heavy bundle scenario.

## Completion Notes
ARGUS now consumes `normalized-analysis.json` and writes cited diagnostic groups and conservative technician recommendations. Gap-only domains produce explicit unsupported conclusions instead of disappearing from output.

## Work Log

### Entry 001
Author: Codex
Date: 2026-07-10
Summary: Activated after TASK-0073 completed and validated the normalized ARGUS evidence model.
Files Changed:
- `docs/TASKS/TASK-0074-ARGUS-Event-Grouping-And-Recommendations.md`
Validation Performed:
- Repository source-of-truth review completed through TASK-0073 handoff.
Issues:
- None.
Instructions for Next Owner:
- Implement ARGUS event grouping and recommendations only within the active TASK-0074 scope.

### Entry 002
Author: Codex
Date: 2026-07-10
Summary: Implemented cited diagnostic grouping and technician recommendations, including explicit missing-evidence boundaries, and integrated both outputs into the ARGUS foundation run.
Files Changed:
- `Core/Argus/ArgusFoundation.ps1`
- `Core/Argus/ArgusRecommendations.ps1`
- `docs/TASKS/TASK-0074-ARGUS-Event-Grouping-And-Recommendations.md`
Validation Performed:
- PowerShell parser validation for all three ARGUS scripts.
- Existing AI bundle run produced parseable `diagnostic-groups.json` and `recommendations.json` with 13 cited groups/recommendations.
- Synthetic normal, limited/gap-only, and problem-heavy normalized bundle scenarios passed.
Issues:
- None.
Instructions for Next Owner:
- Execute TASK-0075 reporting work only.
