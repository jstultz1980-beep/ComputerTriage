# TASK-0117 Performance Audit Findings

Generated local time: 2026-07-17 08:13:26 -05:00

This document records the live toolkit performance audit for planning review.

## Scope

I launched the actual toolkit, exercised the live GUI, switched tabs, and reviewed the performance telemetry emitted by the app.

The audit focused on:

- overall launch time
- first meaningful tab render
- tab switch latency
- heavy embedded-script paths
- startup work that delays user readiness

## Observed timings

Representative measurements from the live app:

- Startup shell to usable window: about 4.5-4.9 seconds
- Quick Diagnosis first render: about 0.44-0.56 seconds
- Quick Diagnosis tab switch: about 0.58-0.75 seconds
- Settings first render: about 0.34 seconds
- Analyze first render: about 1.0 second
- Windows Update first render: about 1.0 second
- Directory first render: about 1.4 seconds
- Print first render: about 5.3 seconds

## Main bottleneck

The largest startup cost is not the window frame itself. The app spends most of its time building the static UI and then immediately queuing a large deferred warm-up set.

The warm-up queue currently schedules 27 tabs on launch. That creates a lot of work before the user gets a fully responsive app, and it is the clearest place to reclaim time.

## What I observed live

- The top-level window was stable during launch.
- The visible client area was not the main source of slowness.
- Deferred tab initialization and embedded script execution dominate the perceived delay.
- Heavy tabs, especially Print and Analyze, are materially slower than the rest.

## Practical speedup ideas

1. Do not warm 27 tabs on launch.
   Warm only the first visible tab, then fill in others during idle time or on demand.

2. Make heavy tabs truly lazy.
   Print, Analyze, Directory, and Windows Update should build in smaller stages or only when opened.

3. Reduce live log and UI churn during startup.
   Avoid forcing extra UI refreshes while the shell is still settling.

4. Split initialization into skeleton-first, data-later phases.
   Show the shell quickly, then populate expensive content asynchronously.

5. Cache static lookups.
   Search indexes, tool metadata, and repeated layout calculations should not be rebuilt every launch.

## Planning conclusion

If Debbie is planning follow-on optimization work, the highest-value sequence is:

1. reduce or remove eager warm-up
2. defer expensive tab construction
3. trim startup UI churn
4. add caching for repeated metadata/layout work

That order should produce the biggest measurable win with the least risk.
