# TASK-0039 - Software Tab Launchable And Installable Inventory

## Status
Queued

## Owner
ChatGPT

## Objective
Define the Software tab inventory model so launchable portable apps and stored installers are clearly separated.

## Scope
- Classify software currently in the toolkit as:
  - Launchable portable apps.
  - Installable programs stored in the toolkit.
  - Unsafe/unfit for toolkit use.
  - Unknown / requires research.
- Identify non-portable tools currently listed in Triage Tools that should move to a Software tab installable area.
- Research whether a usable portable edition of Registrar Registry Manager exists.
- If Registrar Registry Manager cannot be used portably, recommend removing it from launchable toolkit areas and listing it only as installable or excluded.
- Define follow-on Codex implementation tasks for manifest and UI placement changes.

## Out of Scope
- Downloading tools.
- Installing tools.
- Modifying application code.
- Removing files.
- Untracked `App/NetworkToolkit/LatencyMon/`.

## Acceptance Criteria
- [ ] Launchable apps versus installable stored programs are clearly defined.
- [ ] Non-portable Triage Tools are identified for removal from launchable triage listings.
- [ ] Registrar Registry Manager portability is answered with source notes.
- [ ] A follow-on Codex task lists the exact manifest/UI moves to perform.
