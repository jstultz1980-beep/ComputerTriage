# TASK-0029 - Choco Page Layout Refinement

## Status
Queued

## Owner
Codex

## Objective
Rework the Chocolatey tab so the status detail is compact, readable, and no longer wastes top-page real estate.

## Scope
- Make the Chocolatey ready/status area small and useful.
- Avoid a large full-width or half-width empty status frame.
- Keep installed-package management visible and usable.
- Keep package search/install workflow clear.
- Preserve existing Choco actions: install, refresh status, search, install selected, add to toolbox, refresh installed, upgrade all, upgrade selected, uninstall, and check updates.

## Out of Scope
- Changing package installation semantics.
- Changing toolkit app/package manifest format.
- Moving Chocolatey functions to Settings.
- Adding new package sources.
- Untracked `App/NetworkToolkit/LatencyMon/`.

## Acceptance Criteria
- [ ] Chocolatey status no longer consumes a large empty top block.
- [ ] Status text and actions are readable.
- [ ] Installed-package grid and actions remain visible without awkward crowding.
- [ ] Search/install area remains clear.
- [ ] PowerShell parse, smoke, and button-smoke validation pass.
