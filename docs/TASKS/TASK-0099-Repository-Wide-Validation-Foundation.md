# TASK-0099 - Repository-Wide Validation Foundation

## Status
Complete

## Owner
Codex

## Depends On
TASK-0094 minimum; may be implemented incrementally as stabilized contracts become available.

## Objective
Establish repository-wide PowerShell 5.1 parser, module/plugin load, negative-path, package-integrity, artifact-contract, and regression gates.

## Findings Addressed
TASK-0084 testing-gap matrix and DEP-015.

## Acceptance Criteria
- All tracked PowerShell parses under Windows PowerShell 5.1.
- Required module/plugin load completeness is enforced.
- Critical negative-path fixtures execute automatically.
- Package and managed-file manifests are validated.
- Core collection, analysis, ARGUS, report, and GUI contracts have regression coverage.

## Validation
Run the complete repository validation suite against positive and failure fixtures and record results.

## Result

- Added a tracked validation manifest and one Windows PowerShell 5.1 repository entry point with deterministic process exit state, per-stage timeouts, isolated stdout/stderr, optional JSON evidence, and coverage-manifest enforcement.
- Parsed all 82 tracked PowerShell files with zero exclusions.
- Made toolkit smoke fail on any import failure or degraded module/plugin load.
- Added positive and tampered production-package fixtures using the real managed-file and launcher-hash verifier.
- Automatically executed CLI, collection, analysis, ARGUS, reporting, artifact, transaction, provenance, sensitive-state, lifecycle, toolkit, GUI, and button regression gates.
- Final canonical run passed 17 gates with zero failures under Windows PowerShell 5.1.
