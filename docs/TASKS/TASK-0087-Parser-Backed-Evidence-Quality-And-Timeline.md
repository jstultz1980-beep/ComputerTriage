# TASK-0087 - Parser-Backed Evidence Quality and Timeline Semantics

## Status
Complete

## Owner
Codex

## Depends On
TASK-0086.

## Objective
Make evidence quality reflect actual parser and semantic outcomes, and ensure timeline artifacts represent real event time rather than file copy/write time.

## Findings Addressed
- HF-005
- HF-007
- HF-008
- downstream ARGUS confidence amplification

## Scope
- Separate artifact discovery, format validation, parsing, semantic validation, and coverage.
- Never write plain error text under JSON/CSV extensions.
- Record parser warnings and failures by artifact/category.
- Replace or relabel file-metadata chronology.
- Populate a true event timeline only from evidence with event timestamps and source semantics.
- Update evidence-score schema and downstream ARGUS handling.

## Acceptance Criteria
- [x] Every structured artifact either parses or is absent with an explicit error record.
- [x] Empty/malformed/error-text artifacts do not receive parsed credit.
- [x] Failed parser counts and warnings are accurate.
- [x] Event timeline timestamps are source event times with type/source metadata.
- [x] File copy timestamps are never presented as diagnostic event times.

## Validation
Use valid, empty, malformed, truncated, plain-error, and known event/copy timestamp fixtures. Run ARGUS confidence regression checks.

## Work Log
- Added format-aware JSON, CSV, XML, and text validation with separate discovery, parser, semantic, and coverage outcomes.
- Structured collector export failures now produce adjacent `.error.json` envelopes instead of false JSON/CSV artifacts.
- Replaced file-write chronology with source-event-time-only timeline output and explicit timestamp semantics.
- Propagated parser failures, warnings, and timestamp semantics into ARGUS evidence quality and fact confidence.
- Added valid, empty, malformed, truncated, plain-error, event/copy-time, safe-export, and ARGUS regression fixtures.
- PowerShell parser, targeted fixtures, identity regression, triage smoke, toolkit smoke, GUI smoke, and button-smoke validation passed.
