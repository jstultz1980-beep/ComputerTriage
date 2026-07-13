# TASK-0096 - GUI Background Operation Controller Extraction

## Status
Complete

## Owner
Codex

## Depends On
TASK-0095.

## Objective
Create one reusable controller for background processes, jobs, timers, cancellation, timeout, completion, and cleanup; migrate Analyze and Triage first.

## Findings Addressed
PLG-018, PLG-019, PERF-001, and PERF-002.

## Acceptance Criteria
- Analyze and Triage use the shared lifecycle controller.
- Repeated start/cancel/close leaves no leaked processes, jobs, or timers.
- Timeout, failure, cancellation, partial, and success states are distinct.
- Existing GUI behavior remains functional.

## Validation
Repeated start/cancel/close, timeout, failure, success, smoke, and button-smoke tests.

## Result
- Added one reusable controller for process, job, timer, timeout, cancellation, terminal-state, callback, and cleanup ownership.
- Migrated Analyze safe-runner sessions and Triage collection to the shared lifecycle controller.
- Preserved distinct success, partial, failure, timeout, and cancellation outcomes.
- Added repeated replacement/cancel/close leak fixtures covering processes, jobs, and timers.
- Parser, focused controller fixtures, toolkit smoke, GUI smoke, and button-smoke validation passed.
