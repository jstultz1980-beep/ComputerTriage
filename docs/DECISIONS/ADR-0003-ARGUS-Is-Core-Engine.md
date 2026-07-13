# ADR-0003 - ARGUS Is a Core Engine

## Status
Accepted; reconciled by TASK-0097

## Context
ARGUS is the cited explanation, prioritization, and technician-guidance layer for validated HEPHAESTUS evidence and deterministic findings.

## Decision
ARGUS belongs under `Core/Argus`, not `Scripts/ARGUS`. `docs/ARCHITECTURE.md` is the current intended-state runtime authority.

## Consequences
- ARGUS is an internal engine.
- Technician-facing workflows can call ARGUS.
- ARGUS remains scoped to one computer.
