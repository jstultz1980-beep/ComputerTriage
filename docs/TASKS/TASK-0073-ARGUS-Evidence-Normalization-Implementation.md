# TASK-0073 - ARGUS Evidence Normalization Implementation

## Status
Queued

## Owner
Codex

## Purpose
Implement the next ARGUS evidence-normalization layer from the TASK-0072 plan.

## Scope
- Add ARGUS-side loaders for selected HEPHAESTUS outputs.
- Produce a normalized ARGUS intermediate model.
- Preserve deterministic evidence labels and trust boundaries.
- Validate against existing and synthetic bundles.
- Use `docs/DESIGN/ARGUS-PRODUCT-DEFINITION-AND-EVIDENCE-MAP.md` as the implementation contract.
- Preserve existing `ARGUS/input-validation.json`, `ARGUS/analysis-summary.json`, and `ARGUS/report.md`.
- Add `ARGUS/normalized-analysis.json`.

## Out Of Scope
- Broad AI orchestration.
- UI integration.
- Report styling beyond basic validation output.

## Acceptance Criteria
- [ ] ARGUS loads selected evidence domains through structured loaders.
- [ ] Normalized ARGUS model is written as `ARGUS/normalized-analysis.json`.
- [ ] Missing or weak evidence is represented explicitly.
- [ ] Domain, fact, gap, and citation records follow the TASK-0072 design.
- [ ] Parser and ARGUS validation pass.
