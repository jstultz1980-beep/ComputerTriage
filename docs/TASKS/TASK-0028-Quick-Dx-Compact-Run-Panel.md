# TASK-0028 - Quick Dx Compact Run Panel

## Status
Queued

## Owner
Codex

## Objective
Remove the visible fixed internet target list from the Quick Dx page and compact the Quick Diagnosis run block so the right column breathes again.

## Scope
- Keep the hard-coded Quick Diagnosis internet target chain internally.
- Remove the displayed internet target chain from the Quick Diagnosis block.
- Keep only the meaningful action controls: Quick Dx, Report, DISM/SFC, and last-scan status if it fits cleanly.
- Preserve the separate editable Quick Target Checks target field.
- Prevent Hardware Shortcuts from being pushed down or crowded.

## Out of Scope
- Changing Quick Diagnosis collector logic beyond target display/selection plumbing.
- Report content changes.
- Theme redesign.
- Choco, Print, Triage, Computer, or Directory tab changes.
- Untracked `App/NetworkToolkit/LatencyMon/`.

## Acceptance Criteria
- [ ] No internet target list is displayed on the Quick Dx page.
- [ ] Quick Diagnosis still uses the hard-coded target chain in this order: `www.microsoft.com`, `google.com`, `yahoo.com`, `amazon.com`.
- [ ] Quick Diagnosis stops at the first successful target.
- [ ] Quick Dx run block no longer clips labels or pushes Review/Shortcuts down.
- [ ] Hardware Shortcuts remain fully visible at the minimum supported toolkit size.
- [ ] PowerShell parse, smoke, and button-smoke validation pass.
