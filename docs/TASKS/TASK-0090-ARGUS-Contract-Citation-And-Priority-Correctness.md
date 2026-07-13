# TASK-0090 - ARGUS Contract, Citation, and Priority Correctness

## Status
Active

## Owner
Codex

## Depends On
TASK-0086 through TASK-0089.

## Objective
Make ARGUS fail closed on invalid contracts and correct citation identity, domain classification, finding/gap semantics, confidence handling, and recommendation priority ordering.

## Findings Addressed
ARG-001 through ARG-007 and related High findings in the TASK-0084 register.

## Acceptance Criteria
- Invalid or unsupported input does not produce a Completed ARGUS analysis.
- Citations resolve to immutable run artifacts.
- Domain matching is exact and tested.
- Findings and evidence gaps remain distinct.
- All priority values sort correctly.
- Confidence cannot exceed verified upstream evidence quality.

## Validation
Run missing, malformed, unsupported, mixed-domain, all-priority, and citation-tamper fixtures.
