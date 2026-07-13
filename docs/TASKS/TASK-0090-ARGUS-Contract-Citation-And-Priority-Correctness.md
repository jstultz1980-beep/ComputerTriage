# TASK-0090 - ARGUS Contract, Citation, and Priority Correctness

## Status
Complete

## Owner
Codex

## Depends On
TASK-0086 through TASK-0089.

## Objective
Make ARGUS fail closed on invalid contracts and correct citation identity, domain classification, finding/gap semantics, confidence handling, and recommendation priority ordering.

## Findings Addressed
ARG-001 through ARG-007 and related High findings in the TASK-0084 register.

## Acceptance Criteria
- [x] Invalid or unsupported input does not produce a Completed ARGUS analysis.
- [x] Citations resolve to immutable run artifacts.
- [x] Domain matching is exact and tested.
- [x] Findings and evidence gaps remain distinct.
- [x] All priority values sort correctly.
- [x] Confidence cannot exceed verified upstream evidence quality.

## Work Log
- Bound citations to immutable run and bundle identity.
- Replaced substring domain matching with exact normalized category/tag matching.
- Added explicit priority ranking and kept domain-specific gaps isolated.
- Capped deterministic-finding confidence by verified evidence quality.
- Validated failed contracts, mixed domains, all priorities, citation identity, parser, identity, smoke, and button-smoke paths.

## Validation
Run missing, malformed, unsupported, mixed-domain, all-priority, and citation-tamper fixtures.
