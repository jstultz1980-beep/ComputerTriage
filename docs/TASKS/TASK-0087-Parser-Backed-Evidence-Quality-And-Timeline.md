# TASK-0087 - Parser-Backed Evidence Quality and Timeline Semantics

## Status
Queued

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
- [ ] Every structured artifact either parses or is absent with an explicit error record.
- [ ] Empty/malformed/error-text artifacts do not receive parsed credit.
- [ ] Failed parser counts and warnings are accurate.
- [ ] Event timeline timestamps are source event times with type/source metadata.
- [ ] File copy timestamps are never presented as diagnostic event times.

## Validation
Use valid, empty, malformed, truncated, plain-error, and known event/copy timestamp fixtures. Run ARGUS confidence regression checks.
