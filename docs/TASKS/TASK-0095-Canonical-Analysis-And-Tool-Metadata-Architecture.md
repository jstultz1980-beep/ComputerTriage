# TASK-0095 - Canonical Analysis and Tool Metadata Architecture

## Status
Complete

## Owner
Codex

## Depends On
TASK-0094.

## Objective
Remove competing analysis functions, tool catalogs, manifest concepts, and status vocabularies by establishing canonical service and metadata contracts.

## Findings Addressed
RED-001, RED-002, RED-006, RED-008, RED-012, and PLG-016.

## Acceptance Criteria
- Duplicate symbols and competing analysis paths are identified and reconciled.
- One canonical tool metadata source drives tabs, search, launch, and packaging.
- Manifest responsibilities are distinct and documented.
- Status values use the canonical operation-result contract.

## Validation
Duplicate-symbol checks, analysis comparison fixtures, and tool-catalog consistency tests.

## Result
- Removed filename-order HEPHAESTUS function overrides and documented distinct Quick Diagnosis, HEPHAESTUS, ARGUS, and Reporting responsibilities.
- Added normalized canonical tool descriptors consumed by GUI tabs, search, and launch behavior, with external provenance validation.
- Added required plugin discovery, compatibility, enablement, lifecycle, and failure-isolation contracts.
- Defined distinct manifest responsibilities and canonical operation states.
- Parser, canonical architecture fixtures, plugin fixtures, toolkit smoke, GUI smoke, button smoke, diagnostic analysis regression, and whitespace checks passed.
