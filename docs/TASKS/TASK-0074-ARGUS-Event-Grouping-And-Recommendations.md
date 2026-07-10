# TASK-0074 - ARGUS Event Grouping And Recommendations

## Status
Queued

## Owner
Codex

## Purpose
Turn normalized ARGUS facts into coherent diagnostic groups and technician recommendations.

## Scope
- Group related symptoms and events.
- Produce root-cause candidates with confidence.
- Generate technician-facing recommended next actions.
- Cite deterministic findings and normalized evidence for each recommendation.

## Out Of Scope
- UI integration.
- Final report styling.
- Whole-network or multi-machine reasoning.

## Acceptance Criteria
- [ ] ARGUS emits grouped diagnostic themes.
- [ ] Recommendations include confidence and citations.
- [ ] Unsupported conclusions are labeled instead of implied.
- [ ] Validation covers at least one normal, limited, and problem-heavy bundle scenario.
