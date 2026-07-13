# TASK-0021 - HEPHAESTUS Rule Catalog Expansion

## Status
Complete

## Owner
Codex

## Objective
Expand deterministic HEPHAESTUS rule coverage after the v1 local analysis slice is stable and the current GUI cleanup pass is complete.

## Scope
- Add or refine deterministic rules for common workstation and server troubleshooting signals.
- Prioritize service, process, driver, storage, Windows Update, network, security-product, domain-health, DFSR, SYSVOL, and GPO interpretation.
- Prefer structured evidence already collected by HEPHAESTUS before adding new collectors.
- Keep findings specific, explainable, and tied to supporting evidence.
- Preserve the existing HEPHAESTUS and ARGUS evidence contract.

## Out of Scope
- GUI layout work.
- New portable tool downloads.
- ARGUS reasoning changes unless a separate ARGUS task owns them.
- Whole-network inventory or RMM behavior.

## Acceptance Criteria
- [x] New rules produce deterministic findings with clear evidence references.
- [x] Rules avoid generic "needs review" wording when a more specific recommendation is possible.
- [x] Existing HEPHAESTUS output schema remains compatible with ARGUS.
- [x] Local analysis validation passes against at least one existing triage bundle.
- [x] PowerShell parse, smoke, and relevant analysis validation pass.

## Completion Notes
- Added `App/NetworkToolkit/Core/LocalAnalysisRules.ps1` as a companion rule-catalog expansion loaded after the existing local analysis engine.
- Added deterministic text/JSON evidence rules for APIPA network addresses, Windows Update service repair signals, disabled endpoint protection, stopped automatic services, and domain secure-channel/logon failures.
- Preserved the existing HEPHAESTUS output shape and ARGUS-facing artifact paths.
- Validated against the existing `App/NetworkToolkit/Exports/AI-Bundles` folder.
- Validated synthetic evidence for all newly added rule IDs.
- Parser, GUI smoke, and button-smoke validation passed.
