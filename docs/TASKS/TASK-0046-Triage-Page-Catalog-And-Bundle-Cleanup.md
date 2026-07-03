# TASK-0046 - Triage Page Catalog And Bundle Cleanup

## Status
Queued

## Owner
Codex

## Objective
Make the Triage page simpler, remove redundant catalog noise, and improve bundle identification.

## User Need
The Triage page should guide a technician through Quick Triage or Full Triage without extra clutter. The tool catalog should only list tools that matter there, and generated bundles should be easier to identify later.

## Scope
- Move `Quick Triage` and `Full Triage` buttons out of the surrounding box and place them across the top of the tab.
- Remove the visible status block from the Triage page and push that information into the status bar.
- Remove Sysinternals entries from the Triage tool catalog.
- Make WinAudit work if it can run portably; otherwise remove it from the Triage tool catalog.
- Remove catalog applications that already live elsewhere in the toolkit.
- Document or remove the `Export Manifest` action after determining whether it is still useful.
- Make triage bundle names more descriptive for easier identification.

## Out of Scope
- Changing HEPHAESTUS collection semantics.
- Rewriting the triage runner.
- Removing generated manifest artifacts that are still required by ARGUS or reporting.

## Acceptance Criteria
- [ ] Triage primary actions are top-level controls, not boxed inside a status area.
- [ ] Triage status is surfaced through the status bar instead of a large page block.
- [ ] Sysinternals tools are no longer listed in the Triage tool catalog.
- [ ] WinAudit is either working as a portable triage tool or removed from the catalog.
- [ ] Tools already represented elsewhere are removed from the Triage catalog.
- [ ] `Export Manifest` has a clear retained purpose or is removed from the visible UI.
- [ ] Triage bundle names include enough context to identify computer, triage type, and timestamp.
- [ ] PowerShell parse, GUI smoke, button-smoke, and triage service validation pass.
