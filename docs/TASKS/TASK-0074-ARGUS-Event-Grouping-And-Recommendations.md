# TASK-0074 - ARGUS Event Grouping And Recommendations

## Status
Active

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
- [ ] ARGUS emits grouped diagnostic themes.
- [ ] Recommendations include confidence and citations.
- [ ] Recommendations identify blocked or limited conclusions caused by missing evidence.
- [ ] Unsupported conclusions are labeled instead of implied.
- [ ] Validation covers at least one normal, limited, and problem-heavy bundle scenario.

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
