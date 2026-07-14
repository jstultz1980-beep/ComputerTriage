# TASK-0080 - Release Candidate Validation And Documentation

## Status
Queued

## Owner
ChatGPT (Project Custodian)

## Purpose
Run the final release-candidate validation gate and produce release-ready documentation.

## Scope
- Run the full release validation matrix.
- Record known limitations.
- Update quick-start, release notes, and handoff.
- Recommend final GitHub sync/tag behavior.

## Out Of Scope
- New feature implementation.
- Broad UI redesign.
- New embedded tool downloads.

## Acceptance Criteria
- [x] Parser validation passes.
- [x] GUI smoke and button-smoke pass.
- [x] Triage, local analysis, ARGUS, reporting, deployment, update, and package validations pass or have documented limitations.
- [x] Release notes and known limitations are complete.
- [ ] Independent full production image verification passes with no mutable application data.
- [ ] Project Custodian declares the candidate release-ready.

## Codex Validation Result

- The canonical repository gate passed all 18 stages with zero failures.
- A full 6.72 GB production image built successfully with 24,364 files and 24,343 managed entries.
- Independent full-image verification found one release-blocking limitation: four long-path LibreOffice configuration files survived mutable-data cleanup.
- Quick-start, production readiness, known limitations, release evidence, changelog, handoff, and build metadata were reconciled.
- Codex recommended no tag, publication, or distribution until focused remediation or explicit risk acceptance.

## Project Custodian Decision

Risk acceptance is rejected. TASK-0111 is Active to implement fail-closed, long-path-capable mutable-tree cleanup, add a focused fixture, rebuild the full package, and rerun independent verification.

TASK-0080 remains queued as the final Project Custodian release-readiness boundary after TASK-0111 completes. No tagging, publication, or distribution is authorized before that decision.
