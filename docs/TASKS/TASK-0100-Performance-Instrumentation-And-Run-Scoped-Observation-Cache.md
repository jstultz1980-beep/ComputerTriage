# TASK-0100 - Performance Instrumentation and Run-Scoped Observation Cache

## Status
Complete

## Owner
Codex

## Depends On
TASK-0096 and TASK-0099.

## Objective
Add structured timing and provider-health telemetry, define startup and workflow budgets, reduce repeated CIM/event/tool discovery, and create a run-scoped observation cache.

## Findings Addressed
PERF-001 through PERF-012 and superseded TASK-0077 scope.

## Acceptance Criteria
- Startup, first render, tab switch, and major workflows emit timing data.
- Cold and warm baselines are documented.
- Repeated provider queries and scans are reduced without stale cross-run data.
- Provider failures are cached only within safe scope.
- Resource-leak tests pass.

## Validation
Cold/warm startup, first-render, Quick Diagnosis budget, repeated workflow, provider failure, and cache invalidation tests.

## Result

- Added structured, budget-aware timing records for GUI shell startup, first render, tab switches, Quick Diagnosis, Full Triage, HEPHAESTUS, ARGUS, and managed-manifest hashing.
- Added nested run scopes, source timestamps, explicit invalidation, and provider-health suppression that never persists across completed workflows.
- Reused CIM fingerprint/driver observations and Windows Update driver enrichment inside a Quick Diagnosis run without creating cross-run stale state.
- Made the broad Software Key Finder application-registration crawl opt-in and time-bounded.
- Defined versioned budgets and documented cold/warm workstation baselines: 7,590 ms cold GUI process, 5,510 ms warm, 4,543 ms shell, 416 ms first render, and 631 ms tab switch.
- Passed provider failure/retry, cache reuse/invalidation, budget boundary, cold/warm GUI, resource lifecycle, parser, package, full regression, and whitespace checks; the canonical suite passed 18 gates with zero failures.
