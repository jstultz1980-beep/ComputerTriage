# TASK-0100 - Performance Instrumentation and Run-Scoped Observation Cache

## Status
Queued

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