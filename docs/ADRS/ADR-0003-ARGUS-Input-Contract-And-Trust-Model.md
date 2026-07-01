# ADR-0003 - ARGUS Input Contract and Evidence Trust Model

Date: 2026-07-01
Status: Proposed
Task: `TASK-0018-HEPHAESTUS-Local-Analysis-Engine-v1-Design`

## Context

ARGUS is planned as the analysis and explanation engine, but HEPHAESTUS Local Analysis Engine v1 will produce deterministic findings first. ARGUS needs a clear future input contract so it consumes deterministic evidence before making AI-assisted interpretations.

## Decision

ARGUS must treat these HEPHAESTUS artifacts as preferred primary inputs when they exist:

```text
Analysis/findings.json
Analysis/timeline.json
Analysis/evidence-score.json
Analysis/normalized/*.json
Metadata/bundle-capabilities.json
Metadata/schema-version.json
```

ARGUS should use raw evidence as secondary verification and enrichment input.

Trust order:

1. Bundle metadata and schema version.
2. Evidence score and parser warnings.
3. Deterministic HEPHAESTUS findings.
4. Normalized JSON evidence.
5. Raw evidence files.
6. ARGUS inference.

ARGUS must clearly label unsupported inference and should not override deterministic findings without citing conflicting evidence.

## Consequences

- ARGUS implementation remains blocked until enough HEPHAESTUS outputs exist for a meaningful contract.
- ARGUS prompt/report design should distinguish deterministic findings from inference.
- Evidence quality score controls how strongly ARGUS should trust normalized output.

## Status Notes

This ADR is proposed rather than accepted because ARGUS is not active implementation work yet. It should be reviewed and finalized during `TASK-0020-ARGUS-Input-Contract-ADR`.
