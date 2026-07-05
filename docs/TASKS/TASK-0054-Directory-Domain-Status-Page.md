# TASK-0054 - Directory Domain Status Page

## Status
Active

## Owner
Codex

## Objective
Turn the Directory tab into an Active Directory and domain identity status page instead of a simple launcher page.

## Scope
- Show domain join state, current domain, logon DC, secure channel status, and AD site when available.
- Add DNS SRV domain-controller lookup status.
- Keep GPO report access visible.
- Avoid duplicating generic Network or Infrastructure troubleshooting.
- Reuse existing Domain Logon Health and GPO Health logic where practical.

## Out of Scope
- Network adapter, route, DHCP, and latency troubleshooting.
- ARGUS or HEPHAESTUS changes.
- New downloads.

## Acceptance Criteria
- [ ] Directory has a clear AD/domain status summary.
- [ ] Directory does not duplicate Network or Infrastructure checks.
- [ ] Domain Logon Health and GPO Health remain available.
- [ ] Status failures are visible without opening an external console.
- [ ] Parser, smoke, and button-smoke validation pass.
