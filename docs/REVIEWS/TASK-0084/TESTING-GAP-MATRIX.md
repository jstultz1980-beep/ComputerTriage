# Testing Gap Matrix

Task: `TASK-0084-Full-Codebase-Architecture-And-Quality-Audit`
Status: In Progress

## Current Assessment

The repository has useful smoke and button-wiring validation, but its automated coverage is concentrated on successful loading and selected happy paths. The highest-risk negative and partial-failure behaviors are largely untested.

## Matrix

| Area / Path | Existing Validation | Missing Validation | Risk | Required Test Direction |
|---|---|---|---|---|
| Main launcher and CLI exit codes | GUI/CLI launch smoke | Missing command, thrown function, cancellation, partial failure, native child exit propagation | High | Assert deterministic process exit codes for each state |
| Module/plugin loading | Smoke verifies selected commands/catalog | Required module failure, optional plugin failure, duplicate exported function, load-order conflict | High | Synthetic broken module/plugin fixtures and degraded-mode assertions |
| Command registry | Duplicate catalog IDs checked | Duplicate command ID/name replacement behavior and source conflict | Medium | Register conflicting commands and assert explicit failure/diagnostic |
| VBS privilege flow | Manual launch | Non-admin GUI, per-command elevation, denied UAC, read-only workflows | High | Least-privilege launch matrix |
| Triage native command runner | One successful `cmd.exe` echo | timeout, nonzero exit, missing executable, stderr-only failure, killed process cleanup | High | Unit/integration failure fixtures |
| Triage PowerShell collectors | Setup smoke only | Individual collector throw, partial evidence, warning propagation | High | Mock each collector and verify final state/capabilities |
| Triage ZIP and manifest | Existence/readability checks | Final hash correctness, manifest/hash circularity, tamper detection | High | Sidecar/canonical hash validation |
| Triage final status | None for partial failures | preflight false, post-run false, missing outputs, command/tool failures | High | Status-state table tests |
| AI bundle collector | No focused test identified | command false return, writer false return, invalid structured file, section state propagation | High | Section-level result-contract tests |
| Deterministic analysis bundle selection | Manual latest bundle use | unrelated latest folder, empty exports, invalid explicit root, multiple bundles | High | Contract-aware bundle selection fixtures |
| Deterministic machine profile | Existing bundle/manual validation | offline bundle analyzed on different host | Critical | Cross-machine contamination fixture |
| Deterministic evidence score | JSON parse checks | malformed/empty/error text, unrelated matching filename, true parser failure | High | Parser-backed evidence quality fixtures |
| Deterministic timeline | Existence/JSON parse | event timestamp versus file timestamp semantics | High | Known event/copy timestamp fixture |
| Deterministic rerun | No idempotence test | generated output re-entering inventory | High | Run twice and compare canonical output |
| Local analysis failure | Nonfatal behavior manually observed | required artifact write failure, read-only target, malformed evidence | High | Read-only and write-failure fixtures |
| ARGUS input validation | Normal and limited fixtures referenced by tasks | missing required artifact, unsupported schema, malformed required JSON, failed-mode suppression | High | Fail-closed contract suite |
| ARGUS final status | Artifact existence/manual checks | validation failed but return Completed | High | Assert returned state and suppressed recommendations |
| ARGUS citation model | Fixture-based structure checks referenced | source identity mismatch, stale evidence, invalid pointer, duplicate citation, structured value preservation | High | Citation resolution tests |
| ARGUS grouping | Normal/limited/problem-heavy fixtures referenced | contradictory facts, multiple domains, unsupported-only data, evidence-quality gaps across all domains | Medium/High | Deterministic expected group fixtures |
| ARGUS recommendations | Conservative output checks referenced | failed contract, missing citations, confidence downgrade, unsupported conclusion exclusion | High | Recommendation safety assertions |
| Reports | Generated-file checks | malicious Markdown characters, missing machine profile, failed input mode, stale artifacts | Medium | Snapshot/content tests |
| GUI startup | `-SmokeTest` | required module failure, degraded startup, non-admin mode, corrupted settings | High | Headless/synthetic startup matrix |
| GUI button smoke | Control/callback wiring | actual callback outcome, timer cleanup, repeated clicks, cancellation race, failed subprocess result | High | Behavioral UI harness or extracted controller tests |
| GUI async workers | Form-close cleanup call | all timers/jobs/processes disposed; child process survival; event-handler leaks | High | Repeated open/run/close and process leak checks |
| GUI tab performance | Stopwatch/threshold logic exists | repeatable first-render benchmarks and regression threshold | Medium | Timed cold/warm tab-switch test |
| Quick Diagnosis plugin | Broad manual/UI validation | partial command failures, report correctness, invalid state persistence | High | Extract analyzer tests and result-state fixtures |
| Windows Health plugin | Manual actions | denied admin, command failure, partial repair, reboot-required state | Very High | Non-destructive mocks and isolated repair tests |
| Remote Management plugin | Manual actions | firewall/service partial change, rollback, denied permissions, remote endpoint mismatch | Very High | Transaction/rollback integration tests |
| Print Queue cleanup | Manual actions | wrong target, credential failure, partial spooler cleanup, rollback | Very High | Isolated test machine and mocked destructive path |
| Client data transfer | Structured result with warnings | existing destination with Force, partial copy, duplicate filename, insufficient space, path traversal assumptions | High | Destination-content and partial-copy suite |
| Computer state persistence | Manual/UI use | interrupted write, malformed JSON recovery, concurrent writes, lost update | Medium/High | Atomic-write and concurrency tests |
| Retention | Startup invocation | severe evidence outside first ten files, false keyword positives/negatives, deletion permission failure, audit trail | High | Controlled retention fixture tree |
| Fresh deployment | Result JSON and basic required files | wrong dedicated folder, interruption after delete, insufficient disk, locked file, rollback | High | Staged-deployment failure simulations |
| Update | Version comparison and five-file hash check | corrupt plugin/module, locked obsolete file, partial copy, rollback, same-build stale code | High | Full package-manifest and transaction tests |
| Production package | Required paths, four launcher hashes, runtime exclusions | full managed-file integrity, embedded binary provenance/hash, required plugin completeness | High | Complete package manifest verification |
| Build metadata | Task-based update rule | source mutation during failed build, concurrent build, reproducibility | Medium | Build isolation/reproducibility tests |
| Embedded tools | Presence/status checks | hash, signature, architecture, license, quarantine, expected filename mismatch | High | Provenance inventory and signature/hash validation |
| PowerShell 5.1 | `#Requires` and runtime use | parser pass for every `.ps1`, APIs unavailable on PS 5.1, encoding/BOM behavior | High | Repository-wide PS 5.1 parser and compatibility suite |

## Test Architecture Finding

The current UI and plugin monoliths make targeted testing difficult because behavior, state, process launch, analysis, and presentation are frequently co-located. The remediation strategy should not begin with a broad rewrite, but high-risk logic should be extracted behind pure functions or narrow service interfaces as each Critical/High defect is repaired.

## Immediate Required Regression Suite

Before feature work resumes, the audit is likely to require at least these automated gates:

1. Repository-wide PowerShell 5.1 parser validation.
2. Required module/plugin load-completeness validation.
3. CLI exit-code contract tests.
4. Triage partial/failure status tests.
5. Final-bundle integrity test.
6. Offline deterministic-analysis isolation test.
7. Evidence-score parser-validity test.
8. Deterministic-analysis idempotence test.
9. ARGUS failed-contract suppression test.
10. Full managed-payload package/update manifest verification.
