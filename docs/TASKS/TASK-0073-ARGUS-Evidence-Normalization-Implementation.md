# TASK-0073 - ARGUS Evidence Normalization Implementation

## Status
Completed

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
- [x] ARGUS loads selected evidence domains through structured loaders.
- [x] Normalized ARGUS model is written as `ARGUS/normalized-analysis.json`.
- [x] Missing or weak evidence is represented explicitly.
- [x] Domain, fact, gap, and citation records follow the TASK-0072 design.
- [x] Parser and ARGUS validation pass.

## Completion Notes
TASK-0073 is complete. ARGUS now writes `ARGUS/normalized-analysis.json` with domain, fact, gap, and citation records that preserve deterministic evidence boundaries.

## Work Log

### Entry 002
Author: Codex
Date: 2026-07-10
Summary: Implemented ARGUS normalization loaders and the normalized analysis output, then validated the slice against the existing bundle plus synthetic normal and limited bundle scenarios.
Files Changed:
- `Core/Argus/ArgusFoundation.ps1`
- `Core/Argus/ArgusNormalization.ps1`
- `docs/TASKS/TASK-0073-ARGUS-Evidence-Normalization-Implementation.md`
Validation Performed:
- PowerShell parser validation for `Core/Argus/ArgusFoundation.ps1` and `Core/Argus/ArgusNormalization.ps1`.
- Live ARGUS foundation run against `App/NetworkToolkit/Exports/AI-Bundles`.
- Synthetic normal bundle validation in `%TEMP%`.
- Synthetic limited/missing-evidence bundle validation in `%TEMP%`.
- Confirmed `ARGUS/normalized-analysis.json` is written for each case and contains explicit facts, gaps, citations, and domain records.
Issues:
- Preserved known unrelated drift documented in `docs/HANDOFF.md`.
Instructions for Next Owner:
- Activate `TASK-0074-ARGUS-Event-Grouping-And-Recommendations`.
