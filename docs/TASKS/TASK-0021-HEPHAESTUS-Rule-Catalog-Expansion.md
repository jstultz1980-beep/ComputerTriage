# TASK-0021 - HEPHAESTUS Rule Catalog Expansion

## Status
Queued

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
- [ ] New rules produce deterministic findings with clear evidence references.
- [ ] Rules avoid generic "needs review" wording when a more specific recommendation is possible.
- [ ] Existing HEPHAESTUS output schema remains compatible with ARGUS.
- [ ] Local analysis validation passes against at least one existing triage bundle.
- [ ] PowerShell parse, smoke, and relevant analysis validation pass.
