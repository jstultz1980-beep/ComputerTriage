# Performance and Run-Scoped Observation Contract

## Purpose

Network Toolkit measures expensive work with structured, budget-aware timing records and reduces repeated provider calls only within an explicit workflow run. Performance optimization must not turn old observations into current evidence.

## Canonical implementation

`App/NetworkToolkit/Utilities/Performance.ps1` owns:

- named performance runs and nested workflow scope;
- timing records with duration, budget, budget state, timestamp, and tags;
- run-scoped observations with source/provider identity and collection time;
- provider-health state that suppresses repeated calls after a confirmed failure;
- explicit key/provider invalidation;
- JSON result artifacts and Runtime JSONL telemetry.

Budgets are versioned in `App/manifests/performance-budgets.json`.

## Scope and freshness

Every top-level workflow starts a new context. A nested component may reuse its caller’s context only when it is part of the same logical run, as Full Triage does inside Quick Diagnosis. Completing a child restores its parent; completing a top-level run removes its observations and provider state.

No observation or provider failure is reused across completed workflow runs. A caller may invalidate one observation or all observations for a provider inside the current run. Provider retries require explicit invalidation or `-RetryFailedProvider`.

Each observation records `CollectedAtUtc`, state, duration, provider, error, and whether the value came from cache. Missing/failed provider results never masquerade as available values.

## Instrumented surfaces

- GUI shell startup, first tab render, and every tab switch.
- Quick Diagnosis and Full Triage.
- HEPHAESTUS deterministic analysis.
- ARGUS analysis/report generation.
- Managed-file manifest creation and verification.
- Shared CIM observations used by computer fingerprinting and Quick Diagnosis.
- Windows Update driver-candidate enrichment, once per Quick Diagnosis run.

The broad third-party application registration crawl in Software Key Finder is now opt-in and bounded; normal Windows/Office checks remain the default.

## Budget behavior

Quick Diagnosis has an overall 120-second budget. If the core triage consumes that budget, optional status/deep-dive enrichment is skipped and the report records `PerformanceBudgetExceeded` plus an explicit limitation. The Windows Update driver-candidate lookup retains its independent bounded timeout and is cached for the run.

Budget state is evidence, not a hidden cancellation: `WithinBudget`, `Exceeded`, or `Unbudgeted` is recorded for each timing.

## Current workstation baseline

Baseline date: 2026-07-13. Environment: Windows PowerShell `5.1.26100.32995`, repository smoke mode on the current Windows workstation.

| Measurement | Cold | Warm | Budget |
|---|---:|---:|---:|
| GUI process smoke | 7,590 ms | 5,510 ms | 15,000 / 10,000 ms |
| GUI shell ready (representative warm run) | - | 4,543 ms | 10,000 ms |
| Quick Diagnosis first render | - | 416 ms | 3,000 ms |
| Quick Diagnosis tab switch | - | 631 ms | 1,000 ms |

These are regression baselines for this workstation, not universal hardware guarantees. Release validation should capture representative Windows 10/11 workstation, server, VM, and degraded-provider measurements when those environments are available.

## Telemetry

Normal runs append compact JSON records to `Runtime/Logs/Performance/performance.jsonl`. Tests and diagnostic probes can supply a dedicated result path so evidence is isolated and atomically written.
