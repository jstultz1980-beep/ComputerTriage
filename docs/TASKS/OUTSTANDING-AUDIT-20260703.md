# Outstanding Task Audit - 2026-07-03

## Purpose
Map the latest punch-list requests to the task queue and identify duplicates or outstanding work.

## Consolidation Rule
Tasks should be grouped by tab whenever the requested work belongs to a single tab. Cross-cutting work should remain in global tasks only when it affects shared shell behavior, status bar behavior, common styling, performance, data transfer, or architecture.

This prevents a long list of tiny paper-cut tasks while still keeping each implementation pass focused enough to validate safely.

## Request Mapping

| Request | Decision | Task |
|---|---|---|
| Remove `Printing` subheading from Print Diagnostics block. | New focused print polish work. | TASK-0045 |
| Fix clipped `Find Servers` button on Print page. | New focused print polish work. | TASK-0045 |
| Make Computer info section larger and reduce profile table to about three visible rows. | Existing active task updated; this refines the current Computer tab scope. | TASK-0032 |
| Activity tab first-load lag and remaining tab-switch lag. | Existing performance hardening task updated. | TASK-0044 |
| Settings and Help buttons look rough. | Existing modern control style task updated. | TASK-0038 |
| Triage buttons should sit across the top, status should move to status bar. | New focused triage cleanup work. | TASK-0046 |
| Remove Sysinternals from Triage catalog. | New focused triage cleanup work. | TASK-0046 |
| Make WinAudit work or remove it. | New focused triage cleanup work. | TASK-0046 |
| Remove Triage catalog apps that live elsewhere. | New focused triage cleanup work. | TASK-0046 |
| Explain or remove `Export Manifest`. | New focused triage cleanup work. | TASK-0046 |
| Add Wi-Fi signal strength indicator. | Page-level indicator already exists; status-bar placement added separately. | TASK-0036 and TASK-0047 |
| Determine purpose of bottom-right rectangle. | New status-bar cleanup work. | TASK-0047 |
| Make triage bundle names more descriptive. | New focused triage cleanup work. | TASK-0046 |
| Make the crown a little smaller. | Existing modern header/control styling work updated. | TASK-0038 |

## Outstanding Queue Summary

### Active
- TASK-0032 Computer Tab Summary Redesign.

### Queued Codex Implementation
- TASK-0021 HEPHAESTUS Rule Catalog Expansion.
- TASK-0036 Page Health Indicators.
- TASK-0038 Modern Control Style System.
- TASK-0040 Software Tab Launchable And Installable Implementation.
- TASK-0043 Client Data Transfer.
- TASK-0044 GUI Tab Performance Hardening.
- TASK-0045 Print Page Polish.
- TASK-0046 Triage Page Catalog And Bundle Cleanup.
- TASK-0047 Status Bar Wi-Fi And Chrome Cleanup.

### Queued ChatGPT Planning / Review
- TASK-0022 HEPHAESTUS Portable Tool Classification.
- TASK-0033 Directory Tab Direction And Embedding Plan.
- TASK-0034 Embedded Tool Experience Roadmap.
- TASK-0039 Software Tab Launchable And Installable Inventory.

## Recommended Next Task
Continue with active TASK-0032. It is already active, aligns with the current UI cleanup sequence, and directly addresses the Computer tab punch-list item.

## Tab-Based Implementation Buckets

| Bucket | Task | Included Requests |
|---|---|---|
| Computer tab | TASK-0032 | Larger current-computer summary, more details, LED status indicators, profile table reduced to about three visible rows. |
| Print tab | TASK-0045 | Remove unnecessary subheading and fix clipped `Find Servers` control. |
| Triage tab | TASK-0046 | Top-level Quick/Full Triage controls, status-bar status, catalog cleanup, WinAudit decision, `Export Manifest` decision, descriptive bundle names. |
| Activity tab / performance | TASK-0044 | First-open Activity lag and remaining tab-switch lag. |
| Header/shared controls | TASK-0038 | Settings and Help button cleanup plus shared modern utility-button styling. |
| Header/elevation icon | TASK-0038 | Make the crown/elevation icon smaller and less visually dominant. |
| Status bar / Wi-Fi | TASK-0047 and TASK-0036 | Bottom-right chrome cleanup, status-bar Wi-Fi strength, page-level Windows Update and Wi-Fi indicators. |
