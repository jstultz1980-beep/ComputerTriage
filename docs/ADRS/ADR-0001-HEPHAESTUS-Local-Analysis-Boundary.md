# ADR-0001 - HEPHAESTUS Local Analysis Responsibility Boundary

Date: 2026-07-01
Status: Accepted
Task: `TASK-0018-HEPHAESTUS-Local-Analysis-Engine-v1-Design`

## Context

The toolkit mission is rapid single-computer diagnosis. HEPHAESTUS currently owns evidence collection, while ARGUS is planned as the analysis and explanation engine. The project direction now requires deterministic local analysis before AI-assisted interpretation.

## Decision

HEPHAESTUS will own deterministic local analysis for collected evidence.

HEPHAESTUS responsibilities:

- Collect evidence.
- Normalize selected evidence into stable JSON.
- Run deterministic rules.
- Produce structured findings.
- Produce timeline and evidence-quality outputs.
- Produce a local HTML summary report.
- Produce schema and bundle capability metadata.

ARGUS responsibilities remain later-stage interpretation:

- Consume normalized outputs and deterministic findings first.
- Use raw evidence to verify or deepen findings.
- Explain root-cause candidates and recommended actions.
- Clearly separate deterministic evidence from AI inference.

## Consequences

- HEPHAESTUS can provide useful diagnosis without ARGUS.
- ARGUS implementation remains blocked until HEPHAESTUS output contracts are stable.
- HEPHAESTUS collectors should not be modified by the design task.
- Implementation should begin with a small vertical slice rather than a full rule catalog.

## Non-Goals

- ARGUS implementation.
- Whole-network analysis.
- RMM/SIEM behavior.
- Compliance scoring.
