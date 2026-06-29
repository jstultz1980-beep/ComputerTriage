# ADR-0003 - ARGUS Is a Core Engine

## Status
Accepted

## Context
ARGUS is the analysis and explanation engine for HEPHAESTUS evidence bundles.

## Decision
ARGUS belongs under `Core/ARGUS`, not `Scripts/ARGUS`.

## Consequences
- ARGUS is an internal engine.
- Technician-facing workflows can call ARGUS.
- ARGUS remains scoped to one computer.
