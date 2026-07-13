# ADR-0001 - HEPHAESTUS Local Analysis Responsibility Boundary

Date: 2026-07-01
Status: Accepted
Task: `TASK-0018-HEPHAESTUS-Local-Analysis-Engine-v1-Design`

## Current-State Reconciliation

This ADR preserves the context and decision recorded on 2026-07-01. The current intended-state authority is `docs/ARCHITECTURE.md`, as approved by `docs/REVIEWS/TASK-0097/PROJECT-CUSTODIAN-DECISION.md`. HEPHAESTUS now owns collection, evidence normalization, integrity validation, deterministic analysis, and machine-readable outputs. ARGUS is implemented as the cited explanation, prioritization, and technician-guidance layer over validated evidence and deterministic findings.

## Context

At the time of this decision, HEPHAESTUS owned evidence collection while ARGUS was planned as the analysis and explanation engine. The project direction required deterministic local analysis before AI-assisted interpretation.

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
- At the time of this decision, ARGUS implementation remained blocked until HEPHAESTUS output contracts were stable.
- HEPHAESTUS collectors should not be modified by the design task.
- Implementation should begin with a small vertical slice rather than a full rule catalog.

## Non-Goals

- ARGUS implementation.
- Whole-network analysis.
- RMM/SIEM behavior.
- Compliance scoring.
