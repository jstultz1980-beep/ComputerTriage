# TASK-0061 - Directory Page Layout Polish

## Status
Active

## Owner
Codex

## Objective
Fix the Directory page layout follow-up from the punch list after TASK-0054.

## Scope
- Make the Directory page fit better without requiring unnecessary vertical scrolling.
- Remove the Directory page Refresh Status button.
- Preserve the domain identity, secure channel, AD site, logon DC, DNS SRV, Domain Logon Health, GPO Health, GPResult, and Directory tool access created in TASK-0054.
- Keep Directory focused on AD/domain identity and policy health, not generic Network or Infrastructure troubleshooting.

## Out of Scope
- Changing domain check semantics.
- New downloads.
- ARGUS or HEPHAESTUS changes.

## Consolidated Punch-List Mapping
- Punch-list item 30 maps here: Directory page layout needs to be improved and should not require unnecessary scrolling.
- Punch-list item 31 maps here: remove the Directory page refresh button.

## Acceptance Criteria
- [ ] Directory page layout is compact and does not require unnecessary vertical scrolling at normal window size.
- [ ] Refresh Status button is removed.
- [ ] TASK-0054 Directory status and action capabilities remain available.
- [ ] Parser, smoke, and button-smoke validation pass.
