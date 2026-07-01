# TASK-0033 - Directory Tab Direction And Embedding Plan

## Status
Queued

## Owner
ChatGPT

## Objective
Decide whether the Directory tab should remain a tool launcher or become a richer Active Directory/domain insight page, and define follow-on implementation tasks.

## Scope
- Review current Directory tab tools and adjacent Network/Infrastructure tools.
- Decide whether to add useful domain/network discovery information directly on the Directory tab.
- Identify which tools should remain launch buttons versus embedded tab experiences.
- Recommend candidate embedded tools or dedicated tabs.
- Produce focused Codex implementation tasks.

## Design Questions
- Should Directory show domain controller discovery, domain join state, secure channel state, DNS SRV records, site/subnet hints, GPO summary, or AD replication clues?
- Which of those belong on Directory versus Network/Infrastructure/Analyze?
- Which existing launch-only tools should become embedded forms?
- What information can be collected safely and quickly on a random workstation?

## Out of Scope
- Application code changes.
- ARGUS implementation.
- Downloading tools.
- Untracked `App/NetworkToolkit/LatencyMon/`.

## Acceptance Criteria
- [ ] Directory tab direction is explicitly decided.
- [ ] Recommendations avoid duplicating Network and Infrastructure tabs.
- [ ] Embedded-tool candidates are listed and prioritized.
- [ ] Follow-on Codex implementation tasks are created if changes are accepted.
