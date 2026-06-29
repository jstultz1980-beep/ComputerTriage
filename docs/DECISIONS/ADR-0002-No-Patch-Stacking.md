# ADR-0002 - No Patch Stacking

## Status
Accepted

## Context
Repeated patching can make scripts fragile.

## Decision
If a script develops structural problems, stop patching. Roll back and rebuild cleanly.

## Consequences
- Small isolated fixes are acceptable.
- Structural errors require rollback and clean rebuild.
- Task documents must include rollback plans.
