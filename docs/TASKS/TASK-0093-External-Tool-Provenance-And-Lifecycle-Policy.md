# TASK-0093 - External Tool Provenance and Lifecycle Policy

## Status
Active

## Owner
Codex

## Depends On
TASK-0092.

## Objective
Define and enforce source, version, hash, signature, publisher, license, update cadence, privilege, EDR guidance, and package inclusion rules for external tools.

## Findings Addressed
PLG-007 through PLG-010; SEC-002, SEC-004, SEC-008, SEC-009; DEP-012.

## Acceptance Criteria
- Every external tool has a tracked provenance record.
- Hash/signature mismatch blocks use.
- Missing or expired tools are explicit.
- Locally added tools are classified.
- EULA and privilege requirements are documented and enforced.

## Validation
Hash mismatch, signature failure, missing tool, expired tool, local-tool classification, and EULA fixtures.
