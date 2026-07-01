# ADR-0003 - ARGUS Input Contract and Evidence Trust Model

Date: 2026-07-01
Status: Accepted
Task: `TASK-0020-ARGUS-Input-Contract-ADR`

## Context

ARGUS is the future analysis and explanation engine for the Computer Triage Toolkit. HEPHAESTUS Local Analysis Engine v1 now produces validated deterministic outputs under `Analysis/` and `Metadata/`.

The project charter requires deterministic local analysis first, AI-assisted reasoning second, and raw evidence presentation last. ARGUS therefore must consume HEPHAESTUS deterministic outputs as its primary contract and must clearly separate grounded evidence from inference.

## Decision

ARGUS must use HEPHAESTUS Local Analysis Engine outputs as its preferred input contract when they exist.

ARGUS must not rely on raw evidence first when normalized and deterministic artifacts are present. Raw evidence remains available for verification, citation, and enrichment.

## Required Input Artifact Priority

ARGUS must process artifacts in this order:

1. `Metadata/schema-version.json`
2. `Metadata/bundle-capabilities.json`
3. `Analysis/evidence-score.json`
4. `Analysis/findings.json`
5. `Analysis/timeline.json`
6. `Analysis/normalized/machine-profile.json`
7. Other supported `Analysis/normalized/*.json` artifacts
8. `Analysis/report.html` as human-readable context only
9. Raw evidence files as verification/enrichment input
10. ARGUS inference, clearly labeled as inference

The first ARGUS implementation must fail closed if required metadata is missing or unsupported. It may still produce a limited report, but the report must clearly state that the input contract is incomplete.

## Required Minimum ARGUS Inputs

The first ARGUS foundation implementation may run when these files exist and parse:

```text
Metadata/schema-version.json
Metadata/bundle-capabilities.json
Analysis/evidence-score.json
Analysis/findings.json
Analysis/timeline.json
Analysis/normalized/machine-profile.json
```

`Analysis/report.html` is not a machine contract artifact. ARGUS may reference it for technician-facing context but must not parse it as authoritative evidence.

## Trust Model

ARGUS must assign trust in this order:

1. Schema and capability metadata.
2. Evidence-score completeness and quality signals.
3. Deterministic HEPHAESTUS findings.
4. Normalized JSON evidence.
5. Timeline entries.
6. Raw evidence files.
7. ARGUS inference.

Deterministic findings are grounded evidence produced by HEPHAESTUS rules. ARGUS may explain, prioritize, group, or challenge them, but it must not silently override them.

ARGUS may disagree with a HEPHAESTUS finding only when it cites conflicting evidence from normalized or raw artifacts and labels the disagreement as an interpretation.

## Evidence Quality Rules

ARGUS must read `Analysis/evidence-score.json` before interpreting findings.

ARGUS behavior by evidence quality:

- High completeness and high quality: ARGUS may provide normal prioritization and recommendations.
- Partial completeness: ARGUS must include missing-evidence caveats for affected categories.
- Low quality: ARGUS must reduce confidence and avoid strong root-cause language.
- Parser warnings: ARGUS must identify the affected artifact/category and avoid conclusions that depend on failed parsing.
- Missing required metadata: ARGUS must produce a contract failure or limited-mode report, not a normal report.

ARGUS must never invent missing values. Unknown data remains unknown.

## Deterministic Versus Inference Labeling

ARGUS outputs must distinguish:

- `deterministicFinding`: direct HEPHAESTUS finding.
- `normalizedEvidence`: structured evidence from HEPHAESTUS normalized JSON.
- `rawEvidence`: original collected evidence.
- `argusInference`: ARGUS interpretation, explanation, hypothesis, or prioritization.
- `unsupported`: statement that cannot be supported from the bundle.

Every ARGUS recommendation must cite one or more deterministic findings, normalized artifacts, timeline events, raw evidence artifacts, or evidence-quality limitations.

## Missing and Partial Evidence Behavior

If an expected artifact is missing:

- ARGUS must record it in an input validation result.
- ARGUS must determine whether the missing artifact is required or optional.
- ARGUS must continue only in limited mode when safe.
- ARGUS must explain what conclusions cannot be made.

If a capability is marked `planned`, `partial`, `missing`, `skipped`, or `not_implemented` in `Metadata/bundle-capabilities.json`, ARGUS must not report that category as fully analyzed.

## Output Expectations For First ARGUS Foundation

The first ARGUS implementation should produce a small contract-focused output set:

```text
Core/Argus or approved ARGUS path
ARGUS/input-validation.json
ARGUS/analysis-summary.json
ARGUS/report.md or ARGUS/report.html
```

Minimum output concepts:

- Input validation status.
- Parsed artifact inventory.
- Evidence quality summary.
- Prioritized deterministic findings.
- Caveats and unsupported areas.
- ARGUS inference section that is explicitly labeled.

## Consequences

- ARGUS implementation remains blocked until an active implementation task exists.
- ARGUS foundation work should start with input loading and validation, not broad AI reasoning.
- HEPHAESTUS output schemas and capability metadata are now part of ARGUS's contract surface.
- Raw evidence remains important but is not the primary interface between HEPHAESTUS and ARGUS.

## Non-Goals

- Implementing ARGUS in this ADR task.
- Modifying HEPHAESTUS collectors or Local Analysis Engine implementation.
- Defining a final AI prompt strategy.
- Defining full report styling.
- Whole-network analysis.
