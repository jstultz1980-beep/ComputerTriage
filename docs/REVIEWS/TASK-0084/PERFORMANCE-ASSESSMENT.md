# Performance and Responsiveness Assessment

Task: `TASK-0084-Full-Codebase-Architecture-And-Quality-Audit`
Status: In Progress

## Overall Assessment

The project has already introduced deferred rendering, background work, timers, and bounded external-tool execution. Those are positive changes. The remaining performance risk is structural: large scripts repeat expensive discovery and state work, the GUI owns many independent polling lifecycles, and several diagnostics perform broad CIM, registry, event-log, file-system, and external-tool scans in one workflow.

Performance posture: **Operational but difficult to predict and regress-test**.

## Findings

### PERF-001 - GUI startup and runtime are concentrated in one 16,941-line script

Severity: High

The GUI constructs layout, state, event handlers, timers, process runners, settings, catalogs, status indicators, and workflows in one script scope.

Impact:
- expensive initialization is difficult to isolate
- small edits can alter startup ordering
- cold-tab costs are difficult to attribute
- shared script state prevents isolated benchmarking

Recommendation:
Instrument first; extract controllers incrementally. Do not rewrite the GUI wholesale.

### PERF-002 - Each workflow implements its own polling timer and state machine

Severity: Medium/High

Separate timers and process state exist for Quick Diagnosis, triage, update, deployment, Chocolatey, Windows Update, public IP, toolkit sizing, PsExec, and activity refresh.

Impact:
Multiple active timers can overlap, repeat UI work, or survive longer than intended.

Recommendation:
Create a reusable operation monitor and a central timer registry with disposal assertions.

### PERF-003 - Quick Diagnosis is a broad synchronous diagnostic engine

Severity: High

Quick Diagnosis can query CIM/WMI, event logs, services, printers, drivers, Windows Update COM, Sysinternals tools, network checks, and reports.

Impact:
The “quick” path can become slow or variable depending on system health, event-log size, WMI health, update service state, and external tools.

Recommendation:
Define a strict time budget per check and overall workflow. Classify checks as mandatory, optional, and deferred. Emit partial results when the budget is reached.

### PERF-004 - Windows Update driver lookup starts an out-of-process PowerShell job

Severity: Medium

The lookup is bounded by timeout and cleanup, which is positive. However, it creates a full PowerShell job and COM search inside a diagnostic report path.

Impact:
High startup overhead and unpredictable Windows Update service latency.

Recommendation:
Cache results per run and perform only when a finding needs driver-candidate enrichment, as currently intended. Add timing telemetry and ensure no duplicate invocation.

### PERF-005 - Repeated system inventories occur across workflows

Severity: High

Computer profile, Quick Diagnosis, triage, AI collection, Windows Health, GUI summaries, and deterministic analysis independently query overlapping data such as:
- operating system
- computer system
- disks
- services
- drivers
- network adapters
- events
- printers
- processes

Impact:
Repeated CIM/WMI/event queries increase runtime and can amplify failure on unhealthy systems.

Recommendation:
Introduce a run-scoped observation cache with source timestamps and explicit freshness. Consumers should request shared observations rather than requerying by default.

### PERF-006 - Registry crawling in Software Key Finder can be expensive

Severity: Medium/High

The application key scanner traverses up to hundreds of vendor keys and nested children in HKLM/HKCU with broad property inspection.

Impact:
Slow execution on systems with large software registries, especially elevated or on damaged registry providers.

Recommendation:
Make broad application-key crawling optional, bounded by time, and separated from the default Windows/Office key check.

### PERF-007 - Retention scans directories and content during startup

Severity: Medium

Startup may recursively scan report/log/temp folders and inspect file content for severity before deletion.

Impact:
Portable drives and large evidence trees can slow application start.

Recommendation:
Run retention after UI availability, use explicit metadata, and cap work per invocation.

### PERF-008 - Evidence inventory recursively scans generated outputs

Severity: High

Deterministic analysis inventories the entire bundle root, including prior Analysis/Metadata/ARGUS output.

Impact:
Repeated analysis grows work and changes results. Large report trees increase scanning cost.

Recommendation:
Use immutable input directories and exclude generated artifacts.

### PERF-009 - Tool availability and catalog status are recalculated in multiple views

Severity: Medium

External/custom/tool catalog resolution, search indexing, tab status, header indicators, and software inventory can independently check many paths and executables.

Recommendation:
Build one versioned tool-status snapshot and invalidate it only after install/config changes.

### PERF-010 - Event log queries are repeated and broad

Severity: Medium/High

Several plugins and collectors query overlapping System/Application/Setup/provider ranges independently.

Impact:
Slow response on large/corrupt logs and redundant I/O.

Recommendation:
Create a bounded event-query service with shared windows and provider filters, plus timeout/cancellation support.

### PERF-011 - `SilentlyContinue` can convert slow provider failure into repeated retries across features

Severity: Medium

A failing WMI, print, registry, or event provider is often retried by several independent checks because no shared degraded capability is recorded.

Recommendation:
Record run-scoped provider health and avoid repeated calls after a confirmed provider failure unless explicitly retried.

### PERF-012 - Package/update operations lack staged progress and can block on large tool payloads

Severity: Medium

Robocopy handles data transfer efficiently, but full external-tool payloads can be large and verification is currently too narrow to justify skipping broader checks.

Recommendation:
Use a generated manifest to compare only changed files while still validating all required payload identities.

## Measurement Gaps

Current code contains some stopwatch/threshold behavior, but there is no repository-wide performance baseline for:
- cold application startup
- warm startup
- first render by tab
- Quick Diagnosis duration
- full triage duration
- deterministic analysis duration by bundle size
- ARGUS duration by findings count
- report generation duration
- update/deployment duration by payload size
- memory growth after repeated workflows
- leaked processes/jobs/timers after close

## Recommended Performance Test Plan

1. Add structured timing events to startup and each workflow stage.
2. Capture cold/warm baselines on representative Windows 10/11 workstation, server, VM, and degraded-WMI fixture.
3. Add first-render regression thresholds by tab.
4. Run each async workflow repeatedly and verify no process/job/timer growth.
5. Measure duplicate CIM/event calls and introduce run-scoped caching.
6. Set explicit time budgets for Quick Diagnosis and GUI-visible operations.
